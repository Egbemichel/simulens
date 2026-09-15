# SimuLens

**See the outcome before you act.**

SimuLens is a digital twin and simulation-based decision-support platform for urban transportation in Yaoundé, Cameroon. It is a final-year BSc Software Engineering project.

## The Problem

Urban transportation planning in Yaoundé, and in many Cameroonian cities, is largely reactive: infrastructure decisions (road widening, new lanes, signal changes, road closures, repairs) are made without a reliable way to test their effect before implementation. There is no accessible tool that lets planners or researchers simulate an intervention on a real corridor and see, quantitatively, whether it would help or make things worse.

SimuLens addresses this by building a simulation-based digital twin of a real corridor: a model that mirrors the physical road network and traffic behavior closely enough that different interventions can be tested against it, and their outcomes measured, before any real-world change is made.

## Case Study

The initial case study is the **Mvog-Mbi → Poste Centrale corridor** in Yaoundé, Cameroon.

**The exact geographic boundary of this corridor has not yet been finalized.** No coordinates, road segments, intersections, or traffic figures for this corridor exist in this repository. The real road network will be sourced from OpenStreetMap once the boundary is determined, and no geographic or traffic data will be fabricated in the meantime.

## Intended Architecture

SimuLens is organized as a pipeline, from real-world observation to decision support:

```
Real-world observations/data
        ↓
Data layer
        ↓
Digital twin / model
        ↓
SUMO traffic simulation
        ↓
Scenario engine
        ↓
Analytics
        ↓
Decision support
        ↓
3D visualization
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for a detailed breakdown of each component's responsibility.

## Planned Technology

| Layer | Technology |
|---|---|
| Simulation | SUMO |
| Backend / model orchestration | Python, FastAPI |
| Database | PostgreSQL, PostGIS |
| Frontend | Next.js, React, TypeScript |
| 3D visualization | Three.js |
| Geospatial source | OpenStreetMap |
| Analytics | Python |

No additional frameworks or technologies will be introduced unless genuinely necessary.

## Current Development Status

This repository currently contains **project structure and documentation only**. No simulation, backend, frontend, or analytics code has been implemented yet. See [`docs/PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) for a detailed, honest breakdown of what is done versus outstanding.

## Immediate Milestone

The first technical milestone for this project is a successful **baseline simulation**:

```
Real OSM road network
        ↓
SUMO network
        ↓
Vehicles / traffic demand
        ↓
Successful baseline simulation
```

Everything else (scenario comparison, analytics, decision support, 3D visualization) follows only after this foundation is working and calibrated.

## Project Principles

1. This is a digital twin, not merely a 3D visualization.
2. Simulation is the core of the system.
3. The system must eventually support modifying the simulated transportation system itself: road widening, lane additions/removals, turning lanes, signal timing, intersection configuration, road closures, new road connections/bypasses, and road repairs.
4. Traffic demand must be configurable.
5. Road condition must be a simulation variable, since Cameroonian roads can have potholes, poor surfaces, flooding, and seasonal deterioration.
6. Scenarios should eventually be compared using measurable metrics: travel time, delay, queue length, average speed, throughput.
7. Eventually, SimuLens should be able to recommend an intervention based on defined objectives.
8. Validation against observed traffic data is academically important.
9. SimuLens must avoid claiming perfect prediction. The model will be calibrated and validated using measurable error.
10. 3D visualization is important, but it comes after the simulation foundation is in place.

## Repository Structure

```
simulens/
├── docs/            # Project documentation (feasibility, requirements, architecture, methodology, research)
├── data/            # Raw and processed data (no fabricated data — see data/README.md)
├── simulation/       # SUMO network, routes, scenarios, and configs
├── backend/         # Python/FastAPI orchestration layer (not yet implemented)
├── frontend/        # Next.js/React/TypeScript UI (not yet implemented)
├── analytics/       # Python analytics layer (not yet implemented)
├── scripts/         # Reproducible automation scripts
├── tests/           # Automated tests
└── .github/workflows/ # CI configuration
```

## License

See [`LICENSE`](LICENSE).
