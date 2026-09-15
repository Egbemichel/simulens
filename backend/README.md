# Backend

Planned technology: **Python, FastAPI**.

The backend orchestrates the SimuLens pipeline: it will manage the digital twin model, trigger SUMO simulation runs, invoke the analytics layer, and expose an API consumed by the frontend and (eventually) the decision support layer. See [`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) for how this component fits into the overall system.

## Status

Not yet implemented. No backend code exists in this repository. Implementation begins after the simulation foundation (real OSM network → SUMO network → traffic demand → baseline simulation, described in [`../simulation/README.md`](../simulation/README.md)) is working, per the project's simulation-first principle.
