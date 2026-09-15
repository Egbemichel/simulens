# SUMO Run Configuration

## `baseline_smoke_test.sumocfg`

**Baseline Technical Smoke Test — Synthetic Demand.** Ties the real SUMO
network ([`../network/`](../network/)) together with the synthetic/
provisional demand ([`../routes/`](../routes/)) into a runnable simulation.
This is a technical check that the pipeline works end-to-end
(network + demand → simulation), **not** a validated traffic model — see
[`../routes/README.md`](../routes/README.md) for why the demand is
synthetic, and [`../network/README.md`](../network/README.md) for the
network's own known limitations.

### Run it

```
scripts/run_baseline_smoke_test.sh
```

which runs:

```
sumo -c simulation/configs/baseline_smoke_test.sumocfg
```

### What it configures

- **Input**: `simulation/network/mvogmbi_postecentrale_corridor.net.xml` +
  `simulation/routes/synthetic_smoke_test.rou.xml`
- **Time**: 0–1800s (30 simulated minutes), matching the demand window.
- **Output** (written to `data/processed/`, machine-readable, for later
  analytics work):
  - `baseline_smoke_test_tripinfo.xml` — one record per vehicle that
    completed its route (depart/arrival time, duration, route length,
    waiting time, time loss, etc.).
  - `baseline_smoke_test_summary.xml` — one record per simulation second
    (vehicles loaded/inserted/running/arrived, mean speed, mean travel
    time, collisions, teleports, etc.) — a time series of network-wide
    state.

These outputs are themselves **synthetic smoke-test results**, not
observed traffic — see [`../../data/README.md`](../../data/README.md).
