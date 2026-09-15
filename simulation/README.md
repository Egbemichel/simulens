# Simulation

This directory holds everything related to the SUMO (Simulation of Urban MObility) traffic simulation — the core engine of SimuLens.

## Structure

- **`network/`** — SUMO network files (`.net.xml`) describing road geometry, lanes, junctions, and traffic signals for the study corridor, along with the intermediate files used to build them (e.g. `netconvert` inputs/configs).
- **`routes/`** — Traffic demand definitions: vehicle types, trips, and routes (`.rou.xml`) describing how much traffic uses the network and how it flows through it.
- **`scenarios/`** — Named variations on the baseline network and/or demand (e.g. an added turning lane, a road closure, degraded road condition, altered demand) used to compare interventions against the baseline.
- **`configs/`** — SUMO run configuration files (`.sumocfg`) tying a network, a route set, and simulation parameters together into a runnable simulation.

## Why SUMO

SUMO is the simulation engine for SimuLens. It is a microscopic, open-source traffic simulator capable of modeling individual vehicle behavior over a real road network, which is what makes SimuLens a genuine simulation-based digital twin rather than a static visualization.

## Intended Progression

The current development priority is to get a single successful baseline simulation running, following this progression:

```
1. Real OSM road network
        ↓
2. SUMO network
        ↓
3. Vehicles / traffic demand
        ↓
4. Successful baseline simulation
```

1. **Real OSM road network** — **Done.** A real extract of the study corridor
   boundary now exists at
   [`../data/raw/osm/mvogmbi_postecentrale_corridor.osm`](../data/raw/osm/mvogmbi_postecentrale_corridor.osm),
   with its derivation documented in
   [`../docs/methodology/corridor-osm-extraction.md`](../docs/methodology/corridor-osm-extraction.md).
2. **SUMO network** — **Done (structurally), plus a focused cleaning
   pass.** The OSM extract has been converted via `netconvert` into
   [`network/mvogmbi_postecentrale_corridor.net.xml`](network/mvogmbi_postecentrale_corridor.net.xml)
   (667 junctions, 683 real edges, 3,008 lanes). A cleaning pass then
   added a small, explicitly documented set of lane/speed tag values —
   inferred from real OSM evidence where possible, labeled a provisional
   assumption where not — and a geometry fix for corridor-critical
   junction warnings. Full conversion process, exact command, warnings,
   and the complete OBSERVED/OSM-DERIVED/ASSUMED/MODEL-DEFAULT breakdown
   are documented in [`network/README.md`](network/README.md) and
   [`../docs/methodology/network-cleaning.md`](../docs/methodology/network-cleaning.md).
   This network is still **not** calibrated or validated.
3. **Vehicles / traffic demand** — **Done (synthetic/provisional only).**
   [`routes/synthetic_smoke_test.rou.xml`](routes/synthetic_smoke_test.rou.xml)
   holds 258 randomly generated trips — see
   [`routes/README.md`](routes/README.md) for why this is explicitly not
   real or calibrated demand.
4. **Successful baseline simulation** — **Done, as a technical smoke test,
   rerun after network cleaning.**
   [`configs/baseline_smoke_test.sumocfg`](configs/baseline_smoke_test.sumocfg)
   runs the network + synthetic demand end to end: 258/258 vehicles
   inserted, 233 completed their routes within the 1,800s window (237
   before cleaning — fewer complete because the cleaning pass corrected an
   unrealistically fast 100 km/h silent default down to a provisional 50
   km/h on corridor/feeder roads, so trips now take longer; see the
   network-cleaning doc's before/after table), 0 collisions, 0 teleports
   both times. See [`configs/README.md`](configs/README.md). This confirms
   the pipeline works technically — it is **not** a validated or
   calibrated traffic model.

Only after a *calibrated and validated* baseline exists does scenario comparison (varying lanes, signal timing, road condition, closures, demand, etc.) and analytics build on top of it.

## Status

- `network/` contains a structurally valid, cleaned SUMO network generated
  from the real OSM extract (see [`network/README.md`](network/README.md)
  and [`../docs/methodology/network-cleaning.md`](../docs/methodology/network-cleaning.md)),
  including a connectivity check re-verified after cleaning: the full
  drivable network is one connected component, and the corridor is
  routable in both directions.
- `routes/` and `configs/` contain a synthetic-demand baseline smoke test,
  rerun after network cleaning with identical parameters (see
  [`routes/README.md`](routes/README.md) and
  [`configs/README.md`](configs/README.md)). `scenarios/` is still empty —
  scenario work has not started.
- SUMO (`eclipse-sumo` 1.27.1, via `pip install eclipse-sumo`) and `pyproj`
  are installed in the current development environment.
- Nothing in this directory has been calibrated or validated against
  observed traffic. The network still has no signal timing or turn
  restrictions (none exist in the study area — see the network-cleaning
  doc), several corridor lane gaps remain unresolved, and the corridor
  speed value is a provisional assumption, not measured data.
