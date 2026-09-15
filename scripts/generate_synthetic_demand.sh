#!/usr/bin/env bash
# Generates SYNTHETIC/PROVISIONAL traffic demand for the baseline technical
# smoke test. This is NOT observed Yaoundé traffic data -- see
# simulation/routes/README.md for what this is (and is not) for.
#
# Requires SUMO's randomTrips.py (ships under <sumo>/tools) and duarouter
# (used internally by --validate to drop any trip with no valid route).
#
# Usage: scripts/generate_synthetic_demand.sh
set -euo pipefail

NET="simulation/network/mvogmbi_postecentrale_corridor.net.xml"
TRIPS_OUT="simulation/routes/synthetic_smoke_test.trips.xml"
ROUTE_OUT="simulation/routes/synthetic_smoke_test.rou.xml"

SUMO_PKG_DIR="$(python3 -c 'import sumo, os; print(os.path.dirname(sumo.__file__))' 2>/dev/null || true)"
RANDOM_TRIPS="${SUMO_PKG_DIR:+$SUMO_PKG_DIR/tools/randomTrips.py}"
if [ -z "$RANDOM_TRIPS" ] || [ ! -f "$RANDOM_TRIPS" ]; then
  if [ -n "${SUMO_HOME:-}" ] && [ -f "$SUMO_HOME/tools/randomTrips.py" ]; then
    RANDOM_TRIPS="$SUMO_HOME/tools/randomTrips.py"
  else
    echo "Could not find randomTrips.py. Install SUMO first: pip install eclipse-sumo" >&2
    exit 1
  fi
fi

mkdir -p "$(dirname "$TRIPS_OUT")"

# --begin/--end: 1800s (30 simulated minutes) demand window.
# --period 7: one trip inserted roughly every 7s on average (~258 vehicles).
# --vehicle-class passenger: cars only, for this first smoke test.
# --fringe-factor 5: biases trip origins/destinations toward network-boundary
#   edges, so vehicles both enter/exit at the study-area edge and pass
#   through interior intersections, not just spawn/despawn mid-network.
# --min-distance 200: avoids trivial near-zero-length trips.
# --validate: routes every trip through duarouter and DROPS any trip with no
#   valid route, so the output route file only contains routable vehicles --
#   this also doubles as a network-connectivity check.
# --seed 42: fixed seed for reproducibility.
python3 "$RANDOM_TRIPS" \
  -n "$NET" \
  -o "$TRIPS_OUT" \
  -r "$ROUTE_OUT" \
  --begin 0 --end 1800 --period 7 \
  --vehicle-class passenger \
  --prefix veh \
  --fringe-factor 5 \
  --min-distance 200 \
  --validate \
  --seed 42 \
  --random-depart

echo "Trips:  $TRIPS_OUT"
echo "Routes: $ROUTE_OUT"
