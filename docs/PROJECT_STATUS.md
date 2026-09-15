# SimuLens — Project Status

This document tracks the actual state of the SimuLens project. It exists to keep an honest, up-to-date distinction between what has been decided/implemented and what remains outstanding. Nothing in this file should be marked "done" unless it genuinely exists in the repository.

Last updated: 2026-09-15

## DONE

- **Project concept** — Digital twin / simulation-based decision-support platform for urban transportation, defined and documented.
- **Project name** — SimuLens, with tagline "See the outcome before you act."
- **Case study direction** — Mvog-Mbi → Poste Centrale corridor, Yaoundé, Cameroon, selected as the initial study area.
- **Corridor boundary** — Locked at the corridor level using two confirmed endpoint coordinates (Carrefour Mvog-Mbi, Poste Centrale). The connecting road and a minimal extraction bounding box were derived from the real OSM road graph, not guessed — see [`methodology/corridor-osm-extraction.md`](methodology/corridor-osm-extraction.md).
- **Real OSM network acquired** — The raw OSM extract for that bounding box (27,921 nodes / 3,142 ways / 25 relations) is in the repo at [`../data/raw/osm/mvogmbi_postecentrale_corridor.osm`](../data/raw/osm/mvogmbi_postecentrale_corridor.osm), fetched reproducibly via [`../scripts/fetch_osm_corridor.sh`](../scripts/fetch_osm_corridor.sh) from the official OSM API.
- **Architecture direction** — End-to-end pipeline defined: data layer → digital twin/model → SUMO simulation → scenario engine → analytics → decision support → 3D visualization.
- **Technology direction** — Stack selected: SUMO, Python, FastAPI, PostgreSQL/PostGIS, Next.js/React/TypeScript, Three.js, OpenStreetMap.
- **Simulation-first approach** — Explicit project principle that simulation is the core of the system, and 3D visualization is deferred until the simulation foundation works.
- **Repository scaffolding** — Monorepo directory structure and initial documentation created.

## TODO

Roughly in the order they need to happen:

1. **Import into SUMO** — Convert the OSM extract into a SUMO-compatible network (e.g. via `netconvert`). Not yet done — SUMO/`netconvert` is not installed in the current development environment.
2. **Clean network** — Fix import artifacts, and specifically address the data gaps documented in [`methodology/corridor-osm-extraction.md`](methodology/corridor-osm-extraction.md#5-known-data-quality-limitations): sparse `lanes`/`maxspeed` tagging (~18% and ~2% coverage respectively), near-absent traffic-signal/turn-restriction data, so the network is simulation-ready.
3. **Define traffic demand** — Build a configurable vehicle/route demand model for the corridor.
4. **Obtain/process traffic observations** — Collect or source real observed traffic data (counts, speeds, travel times) for the corridor, for later calibration and validation.
5. **Calibrate baseline** — Tune the simulation so its behavior approximates observed conditions.
6. **Validate baseline** — Quantify the error between simulated and observed traffic using defined metrics. No claim of perfect prediction.
7. **Implement scenario engine** — Support modifying the simulated network and demand (lane changes, signal timing, road closures, road condition, etc.) to run comparative "what-if" scenarios.
8. **Implement analytics** — Compute comparison metrics across scenarios: travel time, delay, queue length, average speed, throughput.
9. **Implement decision support** — Recommend interventions based on defined objectives, using the analytics layer.
10. **Implement 3D interface** — Build the Three.js-based 3D visualization on top of the working simulation and analytics stack.

## Explicitly Not Started

- No backend code (FastAPI or otherwise) exists yet.
- No frontend code (Next.js or otherwise) exists yet.
- No SUMO network, route, or scenario files exist yet — the OSM extract has not been converted (see TODO #1).
- No analytics code exists yet.
- No traffic demand, simulation run, or simulation result exists yet.
- No traffic observation data has been obtained, and the network has not been validated against real traffic.
