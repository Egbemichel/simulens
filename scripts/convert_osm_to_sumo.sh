#!/usr/bin/env bash
# Converts the raw OSM corridor extract into a SUMO network using netconvert.
#
# Requires SUMO's netconvert on PATH (or SUMO_HOME set to a SUMO install
# whose bin/ directory contains it). SUMO can be installed with:
#   pip install eclipse-sumo
# which bundles netconvert/sumo binaries under
# <site-packages>/sumo/bin and a typemap under <site-packages>/sumo/data/typemap.
#
# Usage: scripts/convert_osm_to_sumo.sh [input.osm] [output.net.xml]
set -euo pipefail

IN="${1:-data/raw/osm/mvogmbi_postecentrale_corridor.osm}"
OUT="${2:-simulation/network/mvogmbi_postecentrale_corridor.net.xml}"

if ! command -v netconvert >/dev/null 2>&1; then
  echo "netconvert not found on PATH. Install SUMO first, e.g.:" >&2
  echo "  pip install eclipse-sumo" >&2
  echo "and ensure <site-packages>/sumo/bin is on PATH." >&2
  exit 1
fi

SUMO_PKG_DIR="$(python3 -c 'import sumo, os; print(os.path.dirname(sumo.__file__))' 2>/dev/null || true)"
TYPEMAP="${SUMO_TYPEMAP:-}"
if [ -z "$TYPEMAP" ] && [ -n "$SUMO_PKG_DIR" ] && [ -f "$SUMO_PKG_DIR/data/typemap/osmNetconvert.typ.xml" ]; then
  TYPEMAP="$SUMO_PKG_DIR/data/typemap/osmNetconvert.typ.xml"
elif [ -z "$TYPEMAP" ] && [ -n "${SUMO_HOME:-}" ] && [ -f "$SUMO_HOME/data/typemap/osmNetconvert.typ.xml" ]; then
  TYPEMAP="$SUMO_HOME/data/typemap/osmNetconvert.typ.xml"
fi
if [ -z "$TYPEMAP" ]; then
  echo "Could not locate SUMO's osmNetconvert.typ.xml typemap. Set SUMO_TYPEMAP explicitly." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"

echo "Input:   $IN"
echo "Output:  $OUT"
echo "Typemap: $TYPEMAP"

# --geometry.remove   merge redundant intermediate shape nodes (lossless for topology)
# --junctions.join    merge OSM's multi-node intersections into single logical junctions
# --output.original-names / --output.street-names  keep OSM way/street names traceable in the output
#
# Deliberately NOT using osmBuild.py's default --tls.guess-signals / --tls.discard-simple
# / --tls.join: those would add traffic-signal control at junctions that have no
# highway=traffic_signals tag in the source data. At this stage we only want what the
# real OSM data actually encodes; traffic control assumptions are a calibration decision
# for later, not part of a first structural conversion.
netconvert \
  --osm-files "$IN" \
  --type-files "$TYPEMAP" \
  --geometry.remove \
  --junctions.join \
  --output.original-names \
  --output.street-names \
  -o "$OUT"

echo "Done."
