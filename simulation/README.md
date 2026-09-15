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
2. **SUMO network** — **Done (structurally).** The OSM extract has been
   converted via `netconvert` into
   [`network/mvogmbi_postecentrale_corridor.net.xml`](network/mvogmbi_postecentrale_corridor.net.xml)
   (701 junctions, 692 real edges, 3,041 lanes) and loads successfully in
   the SUMO engine. Full conversion process, exact command, warnings, and
   known limitations (default lane/speed values on untagged ways, one lost
   turn restriction, no signal timing) are documented in
   [`network/README.md`](network/README.md). Network cleaning/calibration
   against these gaps has not been done yet.
3. **Vehicles / traffic demand** — Not started.
4. **Successful baseline simulation** — Not started.

Only after this baseline exists and is working does scenario comparison (varying lanes, signal timing, road condition, closures, demand, etc.) and analytics build on top of it.

## Status

- `network/` now contains a structurally valid SUMO network generated from
  the real OSM extract (see [`network/README.md`](network/README.md) for
  full detail). `routes/`, `scenarios/`, `configs/` are still empty — no
  `.rou.xml` or `.sumocfg` files exist yet, and no traffic demand has been
  defined.
- SUMO (`eclipse-sumo` 1.27.1, via `pip install eclipse-sumo`) is installed
  in the current development environment.
- The network has **not** been calibrated or validated against observed
  traffic, and has no signal timing or turn restrictions applied yet.
