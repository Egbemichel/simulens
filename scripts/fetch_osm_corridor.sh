#!/usr/bin/env bash
# Fetches the real OpenStreetMap data covering the Carrefour Mvog-Mbi -> Poste
# Centrale study corridor (Yaounde) via the official OSM API "map" endpoint --
# the same data the openstreetmap.org "Export" feature would return.
#
# Usage: scripts/fetch_osm_corridor.sh [output_path]
#
# The bounding box below was derived in docs/methodology/corridor-osm-extraction.md
# by tracing the shortest drivable path between the two confirmed corridor
# endpoints through the real OSM road graph, then padding that path's bounding
# box by ~300m to capture immediate feeder roads and intersections. It is not
# an arbitrary or invented box -- see that document for the full derivation.
set -euo pipefail

# bbox = minlon,minlat,maxlon,maxlat (WGS84)
MIN_LON="11.51738"
MIN_LAT="3.84821"
MAX_LON="11.52503"
MAX_LAT="3.86465"

OUT="${1:-data/raw/osm/mvogmbi_postecentrale_corridor.osm}"
mkdir -p "$(dirname "$OUT")"

echo "Fetching OSM data for bbox ${MIN_LON},${MIN_LAT},${MAX_LON},${MAX_LAT} ..."
curl -sS --fail \
  -H "User-Agent: SimuLens-research/0.1 (academic project; contact: egbemichel39@gmail.com)" \
  "https://api.openstreetmap.org/api/0.6/map?bbox=${MIN_LON},${MIN_LAT},${MAX_LON},${MAX_LAT}" \
  -o "$OUT"

echo "Saved to $OUT"
echo "Source: OpenStreetMap contributors, ODbL 1.0 (https://www.openstreetmap.org/copyright)"
