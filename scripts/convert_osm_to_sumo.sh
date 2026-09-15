#!/usr/bin/env bash
# Converts the OSM corridor extract into a SUMO network using netconvert.
#
# Defaults to the CLEANED derived OSM file (data/processed/, produced by
# scripts/patch_osm_tags.py from the untouched raw extract) rather than the
# raw file directly -- see docs/methodology/network-cleaning.md for exactly
# what that patch changes and why. Pass an explicit input path to build
# from the raw file instead.
#
# Requires SUMO's netconvert on PATH (or SUMO_HOME set to a SUMO install
# whose bin/ directory contains it). SUMO can be installed with:
#   pip install eclipse-sumo
# which bundles netconvert/sumo binaries under
# <site-packages>/sumo/bin and a typemap under <site-packages>/sumo/data/typemap.
#
# Usage: scripts/convert_osm_to_sumo.sh [input.osm] [output.net.xml]
set -euo pipefail

IN="${1:-data/processed/mvogmbi_postecentrale_corridor_cleaned.osm}"
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
# --default.junctions.radius 10  wider default turning-radius geometry (up from SUMO's
#   default ~4m) -- a purely geometric parameter, not a traffic-data assumption. Added
#   during network cleaning specifically because several corridor/feeder junctions
#   (e.g. the Rue 3.007 and Place d'Awae clusters) produced "intersecting left turns"
#   and sharp-angle warnings at the default radius; see
#   docs/methodology/network-cleaning.md for the before/after warning comparison.
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
  --default.junctions.radius 10 \
  --output.original-names \
  --output.street-names \
  -o "$OUT"

echo "Done."
