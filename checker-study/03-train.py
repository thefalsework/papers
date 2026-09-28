"""Train the from-scratch model (SPEC.md, "Model and training").

Stopping: best validation loss on a 2% slice of the training set, with
patience. Saves models/<profile>/seed<k>.pt and a training log.

Usage: python 03-train.py --profile feasibility|main --seed K [--epochs N]
"""
from __future__ import annotations

import argparse
import json
import random
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import torch

sys.path.insert(0, str(Path(__file__).parent))
from ipl.model import (  # noqa: E402
    CONFIGS, GPT, GPTConfig, encode_pair, lr_at, make_batch,
)

HERE = Path(__file__).parent
TRAIN_SEED_BASE = 1000  # model seed k uses torch/python seed 1000 + k

HYPER = {
    "feasibility": dict(batch=64, lr_max=1e-3, lr_min=1e-4, epochs=40, warmup=100, patience=6),
    "main": dict(batch=128, lr_max=6e-4, lr_min=6e-5, epochs=30, warmup=300, patience=4),
}


def load_jsonl(p: Path):
    with p.open(encoding="utf-8") as fh:
        return [json.loads(line) for line in fh]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", choices=CONFIGS, required=True)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--epochs", type=int, default=None)
    ap.add_argument("--device", default="cuda" if torch.cuda.is_available() else "cpu")
    ap.add_argument("--threads", type=int, default=2, help="CPU threads (keeps a small laptop usable)")
    args = ap.parse_args()
    torch.set_num_threads(args.threads)
    hp = dict(HYPER[args.profile])
    if args.epochs:
        hp["epochs"] = args.epochs

    data_dir = HERE / "data" / args.profile
    meta = json.loads((data_dir / "meta.json").read_text(encoding="utf-8"))
    train = load_jsonl(data_dir / "train.jsonl")
    block = ((meta["max_sequence_tokens"] + 8 + 15) // 16) * 16

    rs = random.Random(TRAIN_SEED_BASE + args.seed)
    torch.manual_seed(TRAIN_SEED_BASE + args.seed)
    rs.shuffle(train)
    n_val = max(1, int(0.02 * len(train)))
    val, tr = train[:n_val], train[n_val:]

    def prep(items):
        seqs, seps = [], []
        for it in items:
            seqs.append(encode_pair(it["formula"], it["proof"]))
            seps.append(len(it["formula"]))  # index of SEP in the sequence
        return seqs, seps

    tr_seqs, tr_seps = prep(tr)
    va_seqs, va_seps = prep(val)

    cfg = GPTConfig(block_size=block, **CONFIGS[args.profile])
    model = GPT(cfg).to(args.device)
    opt = torch.optim.AdamW(model.parameters(), lr=hp["lr_max"], betas=(0.9, 0.95), weight_decay=0.1)
    steps_per_epoch = (len(tr_seqs) + hp["batch"] - 1) // hp["batch"]
    total_steps = steps_per_epoch * hp["epochs"]

    out_dir = HERE / "models" / args.profile
    out_dir.mkdir(parents=True, exist_ok=True)
    ckpt = out_dir / f"seed{args.seed}.pt"
    log = {
        "startedAt": datetime.now(timezone.utc).isoformat(), "profile": args.profile,
        "seed": args.seed, "device": args.device, "n_params": model.n_params(),
        "config": cfg.__dict__, "hyper": hp, "n_train": len(tr_seqs), "n_val": len(va_seqs),
        "block_size": block, "epochs": [],
    }
    print(f"params {model.n_params():,}  block {block}  train {len(tr_seqs)}  val {len(va_seqs)}")

    @torch.no_grad()
    def evaluate():
        model.eval()
        tot, cnt = 0.0, 0
        for i in range(0, len(va_seqs), hp["batch"]):
            x, y = make_batch(va_seqs[i:i + hp["batch"]], va_seps[i:i + hp["batch"]], block, args.device)
            _, loss = model(x, y)
            n = int((y != -100).sum())
            tot += float(loss) * n
            cnt += n
        model.train()
        return tot / max(1, cnt)

    best, bad_epochs, step = float("inf"), 0, 0
    t0 = time.time()
    order = list(range(len(tr_seqs)))
    for epoch in range(hp["epochs"]):
        rs.shuffle(order)
        model.train()
        run, nb = 0.0, 0
        for i in range(0, len(order), hp["batch"]):
            idx = order[i:i + hp["batch"]]
            x, y = make_batch([tr_seqs[j] for j in idx], [tr_seps[j] for j in idx], block, args.device)
            for g in opt.param_groups:
                g["lr"] = lr_at(step, total_steps, hp["warmup"], hp["lr_max"], hp["lr_min"])
            _, loss = model(x, y)
            opt.zero_grad(set_to_none=True)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            opt.step()
            run += loss.item()
            nb += 1
            step += 1
        vl = evaluate()
        rec = {"epoch": epoch, "train_loss": round(run / nb, 4), "val_loss": round(vl, 4),
               "secs": round(time.time() - t0, 1)}
        log["epochs"].append(rec)
        print(rec)
        if vl < best - 1e-4:
            best, bad_epochs = vl, 0
            torch.save({"config": cfg.__dict__, "state": model.state_dict(), "val_loss": vl,
                        "epoch": epoch, "seed": args.seed, "profile": args.profile}, ckpt)
        else:
            bad_epochs += 1
            if bad_epochs >= hp["patience"]:
                print("early stop")
                break
    log["best_val_loss"] = best
    log["finishedAt"] = datetime.now(timezone.utc).isoformat()
    log["train_seconds"] = round(time.time() - t0, 1)
    (out_dir / f"seed{args.seed}.log.json").write_text(json.dumps(log, indent=2), encoding="utf-8")
    print("best val", round(best, 4), "saved", ckpt)
    return 0


if __name__ == "__main__":
    sys.exit(main())
