# SimuLens — Project Status

This document tracks the actual state of the SimuLens project. It exists to keep an honest, up-to-date distinction between what has been decided/implemented and what remains outstanding. Nothing in this file should be marked "done" unless it genuinely exists in the repository.

Last updated: 2026-09-15

## DONE

- **Project concept** — Digital twin / simulation-based decision-support platform for urban transportation, defined and documented.
- **Project name** — SimuLens, with tagline "See the outcome before you act."
- **Case study direction** — Mvog-Mbi → Poste Centrale corridor, Yaoundé, Cameroon, selected as the initial study area.
- **Corridor boundary** — Locked at the corridor level using two confirmed endpoint coordinates (Carrefour Mvog-Mbi, Poste Centrale). The connecting road and a minimal extraction bounding box were derived from the real OSM road graph, not guessed — see [`methodology/corridor-osm-extraction.md`](methodology/corridor-osm-extraction.md).
- **Real OSM network acquired** — The raw OSM extract for that bounding box (27,921 nodes / 3,142 ways / 25 relations) is in the repo at [`../data/raw/osm/mvogmbi_postecentrale_corridor.osm`](../data/raw/osm/mvogmbi_postecentrale_corridor.osm), fetched reproducibly via [`../scripts/fetch_osm_corridor.sh`](../scripts/fetch_osm_corridor.sh) from the official OSM API.
- **SUMO network generated (structural conversion only)** — The OSM extract has been converted via `netconvert` (Eclipse SUMO 1.27.1) into [`../simulation/network/mvogmbi_postecentrale_corridor.net.xml`](../simulation/network/mvogmbi_postecentrale_corridor.net.xml): 701 junctions, 692 real edges, 3,041 lanes, 4,050 connections, and it loads successfully in the SUMO simulation engine. No demand, calibration, or signal timing has been added — see [`../simulation/network/README.md`](../simulation/network/README.md) for the exact command, warnings, and known limitations (default typemap lane/speed values on untagged ways, one lost turn restriction, zero traffic-light logics). A pre-demand connectivity check confirmed the drivable network is a single connected component and the corridor is routable in both directions.
- **Baseline Technical Smoke Test (synthetic demand)** — A first reproducible end-to-end simulation run exists: [`../simulation/configs/baseline_smoke_test.sumocfg`](../simulation/configs/baseline_smoke_test.sumocfg) runs the real network against 258 randomly generated trips ([`../simulation/routes/README.md`](../simulation/routes/README.md) — explicitly synthetic, not observed data). Result: 258/258 vehicles inserted, 237 completed their routes within the 1,800s window, 0 collisions, 0 teleports. This confirms the OSM → SUMO network → demand → simulation pipeline works technically. It is **not** a calibrated or validated traffic model, and must never be cited as such.
- **Architecture direction** — End-to-end pipeline defined: data layer → digital twin/model → SUMO simulation → scenario engine → analytics → decision support → 3D visualization.
- **Technology direction** — Stack selected: SUMO, Python, FastAPI, PostgreSQL/PostGIS, Next.js/React/TypeScript, Three.js, OpenStreetMap.
- **Simulation-first approach** — Explicit project principle that simulation is the core of the system, and 3D visualization is deferred until the simulation foundation works.
- **Repository scaffolding** — Monorepo directory structure and initial documentation created.

## TODO

Roughly in the order they need to happen:

1. **Clean network** — Address the data gaps documented in [`../simulation/network/README.md`](../simulation/network/README.md): sparse `lanes`/`maxspeed` tagging (currently filled with SUMO's generic typemap defaults, not measured values), the one turn restriction that was dropped because its member ways fall outside the extraction bbox, and the sharp-angle/intersecting-left-turn warnings from conversion.
2. **Define a real traffic demand model** — Replace the synthetic smoke-test demand ([`../simulation/routes/README.md`](../simulation/routes/README.md)) with a configurable demand model grounded in an actual understanding of corridor usage (still not real counts until step 3 is done).
3. **Obtain/process traffic observations** — Collect or source real observed traffic data (counts, speeds, travel times) for the corridor, for later calibration and validation.
4. **Calibrate baseline** — Tune the simulation so its behavior approximates observed conditions.
5. **Validate baseline** — Quantify the error between simulated and observed traffic using defined metrics. No claim of perfect prediction.
6. **Implement scenario engine** — Support modifying the simulated network and demand (lane changes, signal timing, road closures, road condition, etc.) to run comparative "what-if" scenarios.
7. **Implement analytics** — Compute comparison metrics across scenarios: travel time, delay, queue length, average speed, throughput.
8. **Implement decision support** — Recommend interventions based on defined objectives, using the analytics layer.
9. **Implement 3D interface** — Build the Three.js-based 3D visualization on top of the working simulation and analytics stack.

## Explicitly Not Started

- No backend code (FastAPI or otherwise) exists yet.
- No frontend code (Next.js or otherwise) exists yet.
- No scenario files exist yet — only a single baseline smoke-test config exists (see TODO #1–2 for what's still needed before this is a real baseline).
- No analytics code exists yet (the smoke test produces raw tripinfo/summary XML only; nothing processes it yet).
- No traffic demand is real — the only demand that exists is randomly generated and explicitly labeled synthetic/provisional.
- No traffic observation data has been obtained, and the network/demand have not been calibrated or validated against real traffic.
