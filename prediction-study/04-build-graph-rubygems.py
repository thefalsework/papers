"""Replication data build: RubyGems dependency graph at T0.

Per SPEC.md Replication section (frozen before parsing): T0 =
2024-09-01; gem exists if >=1 version created_at < T0; edges from the
latest such version; scope = runtime only; targets must exist at T0.
Parses the plain-SQL dump's COPY blocks directly (no PostgreSQL).

Output: data/graph-t0-rubygems.npz, same schema as graph-t0.npz.
"""

import gzip
import io
import sys
import tarfile

import numpy as np

T0 = "2024-09-01"
DUMP = "data/rubygems-dump.tar"
SQL_MEMBER = "public_postgresql/databases/PostgreSQL.sql.gz"

TABLES = {"rubygems", "versions", "dependencies"}


def parse_copy_blocks(lines):
    """Yield (table, columns, row_iter) for COPY blocks of interest."""
    for line in lines:
        if not line.startswith("COPY public."):
            continue
        head = line[len("COPY public."):]
        table = head.split(" ", 1)[0].strip('"')
        cols = head[head.index("(") + 1:head.index(")")]
        columns = [c.strip().strip('"') for c in cols.split(",")]
        if table not in TABLES:
            for row in lines:
                if row.rstrip("\n") == "\\.":
                    break
            continue

        def rows():
            for row in lines:
                row = row.rstrip("\n")
                if row == "\\.":
                    return
                yield row.split("\t")
        yield table, columns, rows()


def main():
    gem_name = {}
    best = {}        # gem_id -> (created_at, version_id)
    first_ver = {}
    n_versions = {}
    version_gem = {}  # needed before deps: selected version_id -> gem_id
    dep_rows = 0
    edges = set()

    with tarfile.open(DUMP, "r") as tar:
        f = tar.extractfile(SQL_MEMBER)
        text = io.TextIOWrapper(gzip.GzipFile(fileobj=f), encoding="utf-8",
                                errors="replace")
        lines = iter(text)
        pending_deps = None
        for table, columns, rows in parse_copy_blocks(lines):
            ix = {c: i for i, c in enumerate(columns)}
            if table == "rubygems":
                for r in rows:
                    gem_name[int(r[ix["id"]])] = r[ix["name"]]
                print(f"rubygems: {len(gem_name)}", flush=True)
            elif table == "versions":
                n = 0
                for r in rows:
                    n += 1
                    created = r[ix["created_at"]]
                    if created == "\\N" or created >= T0:
                        continue
                    gid = int(r[ix["rubygem_id"]])
                    vid = int(r[ix["id"]])
                    n_versions[gid] = n_versions.get(gid, 0) + 1
                    if gid not in best or created > best[gid][0]:
                        best[gid] = (created, vid)
                    if gid not in first_ver or created < first_ver[gid]:
                        first_ver[gid] = created
                print(f"versions: {n} rows, {len(best)} gems at T0",
                      flush=True)
            elif table == "dependencies":
                # dependencies may appear before versions in the dump;
                # buffer raw needed fields if selection not ready
                buf = []
                for r in rows:
                    dep_rows += 1
                    try:
                        scope = r[ix["scope"]]
                        if scope != "runtime":
                            continue
                        vid_s = r[ix["version_id"]]
                        tgt_s = r[ix["rubygem_id"]]
                        if vid_s == "\\N" or tgt_s == "\\N":
                            continue
                        buf.append((int(vid_s), int(tgt_s)))
                    except (IndexError, ValueError):
                        continue
                pending_deps = buf
                print(f"dependencies: {dep_rows} rows, "
                      f"{len(buf)} runtime rows buffered", flush=True)

    selected = {vid: gid for gid, (_, vid) in best.items()}
    exists = set(best)
    for vid, tgt in pending_deps:
        src = selected.get(vid)
        if src is not None and tgt in exists and tgt != src:
            edges.add((src, tgt))
    print(f"T0 edges: {len(edges)}", flush=True)

    node_ids = sorted(exists)
    index = {g: i for i, g in enumerate(node_ids)}
    names = np.array([gem_name.get(g, f"gem-{g}") for g in node_ids])
    src = np.array([index[a] for a, b in edges], dtype=np.int32)
    dst = np.array([index[b] for a, b in edges], dtype=np.int32)
    fv = np.array([first_ver[g] for g in node_ids])
    nv = np.array([n_versions[g] for g in node_ids], dtype=np.int32)

    np.savez_compressed("data/graph-t0-rubygems.npz", names=names,
                        edge_src=src, edge_dst=dst, first_ver=fv,
                        n_versions=nv)
    print(f"graph-t0-rubygems.npz: {len(node_ids)} nodes, {len(edges)} edges")


if __name__ == "__main__":
    sys.exit(main())
