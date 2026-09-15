# Data

This directory holds all data used by SimuLens: geospatial road network data and traffic observation data.

## Structure

- **`raw/`** — Data exactly as obtained from its source, unmodified. Examples (once acquired): an OSM extract (`.osm`/`.pbf`) for the finalized study corridor boundary, raw traffic count sheets, raw speed/travel-time logs.
- **`processed/`** — Data derived from `raw/` through a documented, reproducible process (e.g. a cleaned SUMO network, aggregated traffic counts, a calibrated demand file). Processed data should be regenerable from `raw/` via a script in `scripts/`, not hand-edited.

## Rules

- **No fabricated data.** This directory must never contain invented coordinates, invented road geometry, invented intersections, or invented traffic counts. Every file here must trace back to a real source: OpenStreetMap for geometry, or an actual observation/measurement for traffic data.
- **No data before the boundary is finalized.** The exact boundary of the Mvog-Mbi → Poste Centrale study corridor has not yet been decided. Until it is, no OSM extract or corridor-specific dataset should be added here.
- **Processing must be reproducible.** Any transformation from `raw/` to `processed/` should be done by a script (kept in `scripts/`), not a manual, undocumented step, so the pipeline can be re-run and audited.
- **Large or sensitive raw data need not be committed directly.** If a raw dataset is large or has licensing/privacy constraints, document how to obtain it (source, access method) rather than committing it as-is, and note that in this file when it applies.

Both `raw/` and `processed/` are currently empty placeholders, pending the boundary decision and OSM/traffic data acquisition described in [`../docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md).
