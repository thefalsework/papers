#!/usr/bin/env bash
# Thin orchestration for the checker-study main run (SPEC.md "Sequence" 5-7).
# Calls the frozen scripts in registered order with registered arguments and
# computes nothing itself. Seeds 0, 1, 2; temperatures 1.0 (registered) and
# 0.7 (sensitivity); profile main. Job (seed s, temperature T) runs on GPU s
# for T=1.0 and GPU s+3 for T=0.7; training of seed s runs on GPU s.
#
# Any job failure stops the whole run (exit 1). The registered 1,024-sample
# Monte Carlo rerun (SPEC.md postscript "Resolutions", item H) runs unasked
# only when the job's 256-sample zones stage took under 30 minutes, so that
# four times the containment work stays under two hours; otherwise the script
# logs that the author's decision is needed and exits 3.
#
# Usage (inside tmux):  bash checker-study/run/run-main.sh
# Logs: $LOG/run-main.log (stages, timestamps), $LOG/placement.txt, one log
# per job.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PY=${PY:-/home/ubuntu/venv/bin/python}
LOG=${LOG:-/home/ubuntu/checker-run/logs}
mkdir -p "$LOG"
cd "$REPO"

SEEDS=(0 1 2)
TEMPS=(1.0 0.7)
gpu_for() { local s=$1 t=$2; if [ "$t" = "1.0" ]; then echo "$s"; else echo "$((s + 3))"; fi; }
stamp() { date -u +%Y-%m-%dT%H:%M:%SZ; }
say() { echo "[$(stamp)] $*" | tee -a "$LOG/run-main.log"; }
die() { say "FAILED: $*"; say "RUN STOPPED"; exit 1; }

# run_job <name> <gpu|-> <command...>: background job with its own log and
# start/end stamps; records its pid for wait_all.
PIDS=(); NAMES=()
run_job() {
  local name=$1 gpu=$2; shift 2
  say "start $name (GPU $gpu): $*"
  if [ "$gpu" = "-" ]; then
    ( "$@" > "$LOG/$name.log" 2>&1; rc=$?; echo "[$(stamp)] end $name rc=$rc" >> "$LOG/run-main.log"; exit $rc ) &
  else
    ( CUDA_VISIBLE_DEVICES=$gpu "$@" > "$LOG/$name.log" 2>&1; rc=$?; echo "[$(stamp)] end $name rc=$rc" >> "$LOG/run-main.log"; exit $rc ) &
  fi
  PIDS+=($!); NAMES+=("$name")
}
# wait_all: wait for every job of the stage; any non-zero exit stops the run.
wait_all() {
  local failed=0 i
  for i in "${!PIDS[@]}"; do
    if ! wait "${PIDS[$i]}"; then say "job ${NAMES[$i]} failed (see $LOG/${NAMES[$i]}.log)"; failed=1; fi
  done
  PIDS=(); NAMES=()
  [ "$failed" = 0 ] || die "a job in this stage failed"
}

# ---- placement record
{
  echo "host: $(hostname)  started: $(stamp)  commit: $(git -C "$REPO" rev-parse HEAD)"
  nvidia-smi -L
  for s in "${SEEDS[@]}"; do echo "training seed $s -> GPU $s"; done
  for s in "${SEEDS[@]}"; do for t in "${TEMPS[@]}"; do
    echo "conditions/zones seed $s T=$t -> GPU $(gpu_for "$s" "$t")"
  done; done
} > "$LOG/placement.txt"
say "run-main.sh started; placement in $LOG/placement.txt"

# ---- no registered output may exist before the run
for s in "${SEEDS[@]}"; do
  [ -e "$REPO/models/main/seed$s.pt" ] && die "models/main/seed$s.pt already exists"
done
ls "$REPO"/out/*-main-* >/dev/null 2>&1 && die "out/ already has main-profile files"

# ---- stage 1: train three seeds, one per GPU
say "stage 1 (train) start"
for s in "${SEEDS[@]}"; do
  run_job "03-train-seed$s" "$s" $PY 03-train.py --profile main --seed "$s" --device cuda --threads 8
done
wait_all
for s in "${SEEDS[@]}"; do [ -f "$REPO/models/main/seed$s.pt" ] || die "no checkpoint for seed $s"; done
say "stage 1 (train) end"

# ---- stage 2: six conditions jobs in parallel
say "stage 2 (conditions) start"
for s in "${SEEDS[@]}"; do for t in "${TEMPS[@]}"; do
  run_job "06-conditions-seed$s-T$t" "$(gpu_for "$s" "$t")" \
    $PY 06-conditions.py --profile main --seed "$s" --prompts test --temperature "$t" --device cuda --threads 4
done; done
wait_all
say "stage 2 (conditions) end"

# ---- stage 3: six zone jobs in parallel (kd-tree queries use all cores)
say "stage 3 (zones) start"
for s in "${SEEDS[@]}"; do for t in "${TEMPS[@]}"; do
  run_job "07-zones-seed$s-T$t" "$(gpu_for "$s" "$t")" \
    $PY 07-embed-zones.py --profile main --seed "$s" --temperature "$t" --device cuda --threads 4
done; done
wait_all
say "stage 3 (zones) end"

# ---- stage 4: analysis per seed and temperature
say "stage 4 (analysis) start"
for s in "${SEEDS[@]}"; do for t in "${TEMPS[@]}"; do
  run_job "08-analysis-seed$s-T$t" "-" $PY 08-analysis.py --profile main --seed "$s" --temperature "$t"
done; done
wait_all
say "stage 4 (analysis) end"

# ---- stage 5: three-seed summary per temperature
say "stage 5 (seeds) start"
for t in "${TEMPS[@]}"; do
  run_job "09-seeds-T$t" "-" $PY 09-seeds.py --profile main --seeds 0 1 2 --temperature "$t"
done
wait_all
say "stage 5 (seeds) end"

# ---- stage 6: registered Monte Carlo rerun where 08 recommends it (two-hour rule)
say "stage 6 (Monte Carlo rerun check) start"
ASK=(); RERUN=()
for s in "${SEEDS[@]}"; do for t in "${TEMPS[@]}"; do
  tg=$(printf '%g' "$t")
  A="$REPO/out/analysis-main-seed$s-T$tg.json"; Z="$REPO/out/zones-main-seed$s-T$tg.json"
  rec=$($PY -c "import json,sys; print(json.load(open(sys.argv[1]))['mc_rerun']['recommended'])" "$A") || die "cannot read $A"
  secs=$($PY -c "import json,sys; print(int(json.load(open(sys.argv[1]))['seconds']['total']))" "$Z") || die "cannot read $Z"
  say "seed $s T=$t: mc_rerun recommended=$rec; 256-sample zones stage took ${secs}s"
  if [ "$rec" = "True" ]; then
    if [ "$secs" -lt 1800 ]; then RERUN+=("$s $t"); else ASK+=("seed $s T=$t (${secs}s at 256 samples)"); fi
  fi
done; done
for job in "${RERUN[@]+"${RERUN[@]}"}"; do
  set -- $job; s=$1; t=$2
  run_job "07-zones-seed$s-T$t-mc1024" "$(gpu_for "$s" "$t")" \
    $PY 07-embed-zones.py --profile main --seed "$s" --temperature "$t" --n-mc 1024 --device cuda --threads 4
done
wait_all
for job in "${RERUN[@]+"${RERUN[@]}"}"; do
  set -- $job; s=$1; t=$2
  run_job "08-analysis-seed$s-T$t-mc1024" "-" $PY 08-analysis.py --profile main --seed "$s" --temperature "$t" --n-mc 1024
done
wait_all
if [ "${#ASK[@]}" -gt 0 ]; then
  say "NEEDS DECISION: the 1,024-sample rerun is recommended but would exceed two hours for: ${ASK[*]}"
  say "RUN STOPPED before those reruns (exit 3)"
  exit 3
fi
say "stage 6 (Monte Carlo rerun check) end"
say "ALL DONE"
