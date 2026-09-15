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
- **`processed/`** — Data derived from `raw/` through a documented, reproducible process (e.g. a cleaned SUMO network, aggregated traffic counts, a calibrated demand file). Processed data should be regenerable from `raw/` via a script in `scripts/`, not hand-edited. Currently empty — no processing has been done yet.

## Rules

- **No fabricated data.** This directory must never contain invented coordinates, invented road geometry, invented intersections, or invented traffic counts. Every file here must trace back to a real source: OpenStreetMap for geometry, or an actual observation/measurement for traffic data.
- **Processing must be reproducible.** Any transformation from `raw/` to `processed/` should be done by a script (kept in `scripts/`), not a manual, undocumented step, so the pipeline can be re-run and audited.
- **Large or sensitive raw data need not be committed directly.** If a raw dataset is large or has licensing/privacy constraints, document how to obtain it (source, access method) rather than committing it as-is, and note that in this file when it applies.

See [`../docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md) for what data acquisition remains outstanding (traffic observations, in particular).
