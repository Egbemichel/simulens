#!/usr/bin/env bash
# Runs the Baseline Technical Smoke Test: the SUMO network plus SYNTHETIC/
# PROVISIONAL demand, headless, producing tripinfo/summary output.
# This is NOT a calibrated or validated simulation -- see
# simulation/routes/README.md.
#
# Usage: scripts/run_baseline_smoke_test.sh
set -euo pipefail

if ! command -v sumo >/dev/null 2>&1; then
  echo "sumo not found on PATH. Install SUMO first: pip install eclipse-sumo" >&2
  exit 1
fi

mkdir -p data/processed

sumo -c simulation/configs/baseline_smoke_test.sumocfg
