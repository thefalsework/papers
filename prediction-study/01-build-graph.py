"""Phase 0 data build: reconstruct the crates.io dependency graph at T0.

Per SPEC.md (frozen): T0 = 2024-09-01 00:00 UTC. A crate exists at T0
if it has >= 1 version with created_at < T0; its edges are those of its
latest version by created_at < T0; dependency rows with kind = 0
(normal) only, optional included, all targets; edges to crates not
existing at T0 dropped. No outcome data is touched here.

Output: data/graph-t0.npz
  names            (str array, node index -> crate name)
  edge_src/edge_dst (int32, p depends on q: src -> dst)
  first_ver        (str, first version created_at per node)
  n_versions       (int32, versions before T0 per node)
"""

import csv
import io
import sys
import tarfile

import numpy as np

T0 = "2024-09-01"
DUMP = "data/db-dump.tar.gz"

csv.field_size_limit(1 << 24)


def stream_csv(tar, name_suffix):
    for member in tar:
        if member.name.endswith(name_suffix):
            f = tar.extractfile(member)
            reader = csv.DictReader(io.TextIOWrapper(f, encoding="utf-8"))
            return reader, member.name
    raise KeyError(name_suffix)


def main():
    # Pass 1: crates.csv (id -> name), versions.csv (select latest < T0).
    crate_name = {}
    best = {}        # crate_id -> (created_at, version_id)
    first_ver = {}   # crate_id -> earliest created_at < T0
    n_versions = {}  # crate_id -> count of versions < T0

    with tarfile.open(DUMP, "r:gz") as tar:
        reader, member = stream_csv(tar, "data/crates.csv")
        for row in reader:
            crate_name[int(row["id"])] = row["name"]
        print(f"crates.csv ({member}): {len(crate_name)} crates", flush=True)

    with tarfile.open(DUMP, "r:gz") as tar:
        reader, member = stream_csv(tar, "data/versions.csv")
        nrows = 0
        for row in reader:
            nrows += 1
            created = row["created_at"]
            if created >= T0:
                continue
            cid = int(row["crate_id"])
            vid = int(row["id"])
            n_versions[cid] = n_versions.get(cid, 0) + 1
            if cid not in best or created > best[cid][0]:
                best[cid] = (created, vid)
            if cid not in first_ver or created < first_ver[cid]:
                first_ver[cid] = created
        print(f"versions.csv: {nrows} rows, {len(best)} crates exist at T0",
              flush=True)

    selected = {vid: cid for cid, (_, vid) in best.items()}
    exists = set(best)

    # Pass 2: dependencies.csv -> edges of selected versions, kind 0.
    edges = set()
    with tarfile.open(DUMP, "r:gz") as tar:
        reader, member = stream_csv(tar, "data/dependencies.csv")
        nrows = 0
        for row in reader:
            nrows += 1
            if row["kind"] != "0":
                continue
            vid = int(row["version_id"])
            src = selected.get(vid)
            if src is None:
                continue
            dst = int(row["crate_id"])
            if dst in exists and dst != src:
                edges.add((src, dst))
        print(f"dependencies.csv: {nrows} rows, {len(edges)} T0 edges",
              flush=True)

    node_ids = sorted(exists)
    index = {cid: i for i, cid in enumerate(node_ids)}
    names = np.array([crate_name[cid] for cid in node_ids])
    src = np.array([index[a] for a, b in edges], dtype=np.int32)
    dst = np.array([index[b] for a, b in edges], dtype=np.int32)
    fv = np.array([first_ver[cid] for cid in node_ids])
    nv = np.array([n_versions[cid] for cid in node_ids], dtype=np.int32)

    np.savez_compressed("data/graph-t0.npz", names=names, edge_src=src,
                        edge_dst=dst, first_ver=fv, n_versions=nv)
    print(f"graph-t0.npz: {len(node_ids)} nodes, {len(edges)} edges")


if __name__ == "__main__":
    sys.exit(main())
