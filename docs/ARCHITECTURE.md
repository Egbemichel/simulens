# SimuLens — Architecture

This document describes the proposed architecture of SimuLens and the responsibility of each major component. It describes intent, not implementation status — see [`PROJECT_STATUS.md`](PROJECT_STATUS.md) for what actually exists.

## Pipeline Overview

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

Each stage consumes the output of the stage above it. The system is designed so that the simulation core can function correctly and be validated before any presentation layer (3D visualization) is built on top of it.

## Component Responsibilities

### 1. Real-world observations/data

Ground-truth inputs to the system: OpenStreetMap road geometry for the study corridor, and observed traffic data (counts, speeds, travel times) where available. This stage is the source of truth used later for calibration and validation. No data at this stage is generated or estimated by SimuLens — it is collected or sourced externally.

### 2. Data layer

Responsible for storing, versioning, and serving both geospatial and observational data. Backed by PostgreSQL with the PostGIS extension for geospatial queries. Holds the corridor's road geometry, any observed traffic datasets, and derived/processed data used by the model and simulation layers.

### 3. Digital twin / model

The structured representation of the real corridor: its network topology, intersections, lane configurations, and controllable attributes (road condition, signal timing, lane counts, etc.). This is the layer that makes SimuLens a *digital twin* rather than a one-off simulation script — it is the persistent, modifiable model of the real corridor that all simulations are derived from.

### 4. SUMO traffic simulation

The simulation engine. Takes a SUMO network (derived from the digital twin) and a traffic demand definition, and executes microscopic traffic simulation. Produces raw simulation output (trajectories, timing, counts) for a given network + demand + configuration combination.

### 5. Scenario engine

Responsible for generating and managing simulation *scenarios*: variations on the baseline digital twin (e.g. an added turning lane, a road closure, a changed signal timing, degraded road condition, altered demand) that can each be run through the SUMO simulation and compared against the baseline and against each other.

### 6. Analytics

Processes raw simulation output from one or more scenario runs into measurable, comparable metrics: travel time, delay, queue length, average speed, throughput. Also responsible for computing calibration/validation error against observed data.

### 7. Decision support

Uses the analytics layer's metrics, combined with defined objectives (e.g. minimize average delay, maximize throughput), to recommend interventions among the scenarios evaluated. This layer is explicitly framed as decision *support*, not automated decision-making — it surfaces evidence and comparisons, not unilateral conclusions.

### 8. 3D visualization

Presents the digital twin and simulation results visually, built with Three.js. This is the outermost layer and depends on a working simulation and analytics foundation underneath it. It is deliberately sequenced last.

## Supporting Layers

- **Backend (Python/FastAPI)** — Orchestrates the pipeline: manages the digital twin model, triggers SUMO simulation runs, runs analytics, and exposes an API for the frontend and decision support layer.
- **Frontend (Next.js/React/TypeScript)** — User-facing application for configuring scenarios, viewing analytics, and (eventually) the 3D visualization.

## Design Notes

- The architecture is intentionally simulation-first: everything above the SUMO simulation layer depends on it working correctly, so it is built and validated first.
- Traffic demand and road condition are treated as first-class, configurable simulation variables, not hardcoded assumptions, because they vary significantly in the target context.
- Validation against observed data is treated as a required step, not an optional one — SimuLens reports calibrated, measurable error rather than claiming predictive accuracy it hasn't demonstrated.
