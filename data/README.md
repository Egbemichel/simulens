# Data

This directory holds all data used by SimuLens: geospatial road network data and traffic observation data.

## Structure

- **`raw/`** — Data exactly as obtained from its source, unmodified.
  Currently contains `raw/osm/mvogmbi_postecentrale_corridor.osm`, the real
  OpenStreetMap extract for the study corridor bounding box (see
  [`raw/osm/README.md`](raw/osm/README.md) and
  [`../docs/methodology/corridor-osm-extraction.md`](../docs/methodology/corridor-osm-extraction.md)
  for how the boundary was derived and where the file came from). Will also
  hold raw traffic count sheets / speed / travel-time logs once obtained.
- **`processed/`** — Data derived from `raw/` (or generated) through a documented, reproducible process. Currently contains:
  - `mvogmbi_postecentrale_corridor_cleaned.osm` — a derived copy of the raw OSM extract with a small, explicitly documented set of lane/speed tag additions, produced by `scripts/patch_osm_tags.py`. See [`../docs/methodology/network-cleaning.md`](../docs/methodology/network-cleaning.md) for every value added, its source, and which are OSM-inferred vs. provisional assumptions. The raw file itself is never modified.
  - `baseline_smoke_test_tripinfo.xml` / `baseline_smoke_test_summary.xml` — output of the **Baseline Technical Smoke Test**, produced by `scripts/run_baseline_smoke_test.sh` from **synthetic/provisional** demand — see [`../simulation/routes/README.md`](../simulation/routes/README.md). These are simulation outputs from randomly generated traffic, not observed data.

## Rules

- **No fabricated data presented as real.** This directory must never contain invented coordinates, invented road geometry, invented intersections, or invented traffic counts presented as if they were real. Every *source* file here must trace back to an actual origin: OpenStreetMap for geometry, an actual observation/measurement for traffic data, or — for synthetic simulation inputs/outputs like the smoke-test files above — must be unambiguously labeled as synthetic and never cited as observed Yaoundé traffic.
- **Processing must be reproducible.** Any transformation from `raw/` to `processed/` should be done by a script (kept in `scripts/`), not a manual, undocumented step, so the pipeline can be re-run and audited.
- **Large or sensitive raw data need not be committed directly.** If a raw dataset is large or has licensing/privacy constraints, document how to obtain it (source, access method) rather than committing it as-is, and note that in this file when it applies.

See [`../docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md) for what data acquisition remains outstanding (traffic observations, in particular).
