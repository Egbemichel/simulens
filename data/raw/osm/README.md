# Raw OSM Data — Mvog-Mbi → Poste Centrale Corridor

`mvogmbi_postecentrale_corridor.osm` is the unmodified OpenStreetMap
extract for the study corridor's bounding box, fetched from the official
OSM API `map` endpoint (the same data source as the openstreetmap.org
"Export" feature).

- **How it was derived and why this bounding box:**
  [`docs/methodology/corridor-osm-extraction.md`](../../../docs/methodology/corridor-osm-extraction.md)
- **How to regenerate it:**
  `scripts/fetch_osm_corridor.sh` (reproducible; same bbox, same source)
- **Retrieved:** 2026-09-15
- **License:** © OpenStreetMap contributors, ODbL 1.0 —
  https://www.openstreetmap.org/copyright
- **Contents:** full raw export for the bbox (27,921 nodes / 3,142 ways / 25
  relations) — all OSM feature types, not filtered to roads only. Filtering
  to a SUMO-ready road network happens later, in `simulation/network/`, via
  `netconvert`, and will be a separate, documented processing step.

This file must not be hand-edited. If the study boundary changes, regenerate
it with the fetch script rather than editing it in place.
