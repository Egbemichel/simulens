# Traffic Demand — Baseline Technical Smoke Test

## ⚠️ SYNTHETIC / PROVISIONAL — NOT OBSERVED YAOUNDÉ TRAFFIC

Everything in this directory is **randomly generated synthetic demand**,
created only to technically exercise the SUMO network (can vehicles enter,
route through intersections, and exit without the simulation breaking). It
is **not** derived from any traffic count, survey, or observation in
Yaoundé, and must never be presented, cited, or reused as if it were real
or calibrated traffic data. See project principle #8/#9 in the root
[`README.md`](../../README.md): validation against observed data is
required before any real claim is made, and this repository does not claim
predictive accuracy.

## Files

- **`synthetic_smoke_test.trips.xml`** — raw random trips (origin/destination
  edge pairs + departure time) before routing.
- **`synthetic_smoke_test.rou.xml`** — the same trips routed through
  `duarouter` (via `randomTrips.py --validate`), i.e. the actual vehicle
  route definitions SUMO simulates.

## How it was generated

```
scripts/generate_synthetic_demand.sh
```

which runs (exact command, reproducible with `--seed 42`):

```
randomTrips.py \
  -n simulation/network/mvogmbi_postecentrale_corridor.net.xml \
  -o simulation/routes/synthetic_smoke_test.trips.xml \
  -r simulation/routes/synthetic_smoke_test.rou.xml \
  --begin 0 --end 1800 --period 7 \
  --vehicle-class passenger \
  --prefix veh \
  --fringe-factor 5 \
  --min-distance 200 \
  --validate \
  --seed 42 \
  --random-depart
```

- **1800s (30 simulated minutes)** demand window, **~7s** average interval
  between vehicle insertions → **258 trips generated**.
- **`passenger`** vehicle class only (cars) — no buses, trucks, or
  pedestrians modeled in this first test.
- **`--fringe-factor 5`** biases random origins/destinations toward edges at
  the network's boundary, so vehicles realistically enter and exit the
  study area rather than only spawning/despawning mid-network.
- **`--validate`** routes every trip through `duarouter` and **drops** any
  trip with no valid route — this is also a live connectivity check. Result:
  **all 258 generated trips were routable; 0 were dropped.**
- **`--seed 42`** makes the output deterministic — rerunning the script
  produces byte-identical trips/routes (only the generator's timestamp
  comment differs).

## Why this design, and its limits

This demand is deliberately simple, per the current task's scope — it is a
**technical smoke test**, not calibration:

- No time-of-day demand pattern (e.g. no AM/PM peak) — flat random arrival
  over the window.
- No distinction between through-traffic, local trips, or trip purpose.
- No real vehicle counts, OD matrix, or mode split from any source.
- Passenger cars only.

None of this is meant to resemble actual Yaoundé traffic conditions on the
Mvog-Mbi → Poste Centrale corridor. Building a demand model that does is a
separate, later task (see [`../../docs/PROJECT_STATUS.md`](../../docs/PROJECT_STATUS.md)),
requiring real traffic observations this project does not yet have.
