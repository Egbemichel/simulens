# SimuLens — Project Status

This document tracks the actual state of the SimuLens project. It exists to keep an honest, up-to-date distinction between what has been decided/implemented and what remains outstanding. Nothing in this file should be marked "done" unless it genuinely exists in the repository.

Last updated: 2026-09-15

## DONE

- **Project concept** — Digital twin / simulation-based decision-support platform for urban transportation, defined and documented.
- **Project name** — SimuLens, with tagline "See the outcome before you act."
- **Case study direction** — Mvog-Mbi → Poste Centrale corridor, Yaoundé, Cameroon, selected as the initial study area (exact boundary not yet finalized — see TODO).
- **Architecture direction** — End-to-end pipeline defined: data layer → digital twin/model → SUMO simulation → scenario engine → analytics → decision support → 3D visualization.
- **Technology direction** — Stack selected: SUMO, Python, FastAPI, PostgreSQL/PostGIS, Next.js/React/TypeScript, Three.js, OpenStreetMap.
- **Simulation-first approach** — Explicit project principle that simulation is the core of the system, and 3D visualization is deferred until the simulation foundation works.
- **Repository scaffolding** — Monorepo directory structure and initial documentation created.

## TODO

Roughly in the order they need to happen:

1. **Finalize exact geographic boundary** — Determine the precise extent of the Mvog-Mbi → Poste Centrale corridor (which streets, which intersections, what buffer). This is a human decision and a prerequisite for all downstream geographic work.
2. **Acquire OSM network** — Extract the real road network for the finalized boundary from OpenStreetMap.
3. **Import into SUMO** — Convert the OSM extract into a SUMO-compatible network (e.g. via `netconvert`).
4. **Clean network** — Fix import artifacts (disconnected edges, incorrect lane counts, missing turn restrictions, etc.) so the network is simulation-ready.
5. **Define traffic demand** — Build a configurable vehicle/route demand model for the corridor.
6. **Obtain/process traffic observations** — Collect or source real observed traffic data (counts, speeds, travel times) for the corridor, for later calibration and validation.
7. **Calibrate baseline** — Tune the simulation so its behavior approximates observed conditions.
8. **Validate baseline** — Quantify the error between simulated and observed traffic using defined metrics. No claim of perfect prediction.
9. **Implement scenario engine** — Support modifying the simulated network and demand (lane changes, signal timing, road closures, road condition, etc.) to run comparative "what-if" scenarios.
10. **Implement analytics** — Compute comparison metrics across scenarios: travel time, delay, queue length, average speed, throughput.
11. **Implement decision support** — Recommend interventions based on defined objectives, using the analytics layer.
12. **Implement 3D interface** — Build the Three.js-based 3D visualization on top of the working simulation and analytics stack.

## Explicitly Not Started

- No backend code (FastAPI or otherwise) exists yet.
- No frontend code (Next.js or otherwise) exists yet.
- No SUMO network, route, or scenario files exist yet.
- No analytics code exists yet.
- No real or synthetic data (geographic or traffic) has been added to this repository.
