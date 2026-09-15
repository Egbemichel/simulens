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

1. **Real OSM road network** — A real extract of the study corridor from OpenStreetMap, once its boundary is finalized (see [`../docs/PROJECT_STATUS.md`](../docs/PROJECT_STATUS.md)). Not fabricated.
2. **SUMO network** — The OSM extract converted into a SUMO network (typically via `netconvert`), then cleaned of import artifacts.
3. **Vehicles / traffic demand** — A configurable definition of vehicles and routes representing traffic on the corridor.
4. **Successful baseline simulation** — Running the network and demand together in SUMO to produce a working, inspectable baseline simulation of the corridor.

Only after this baseline exists and is working does scenario comparison (varying lanes, signal timing, road condition, closures, demand, etc.) and analytics build on top of it.

## Status

No network, route, scenario, or config files exist yet. This directory is currently structural only, pending the OSM data acquisition described in `data/README.md` and `docs/PROJECT_STATUS.md`.
