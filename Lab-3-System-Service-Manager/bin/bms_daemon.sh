Bash


#!/usr/bin/env bash
# ==============================================================================
# Script: bms_daemon.sh
# Description: Simulates an EV Battery Management System (BMS) daemon.
#              Outputs health telemetry to stdout/stderr for journalctl.
# ==============================================================================

set -euo pipefail

echo "[BMS INIT] Starting Rivian Virtual BMS Daemon (PID: $$)..."
echo "[BMS INIT] Initializing high-voltage battery contactors..."

SOC=100
VOLTAGE=400

while true; do
    # Simulate battery drain and status output
    echo "[BMS TELEMETRY] Pack Voltage: ${VOLTAGE}V | SoC: ${SOC}% | Status: NOMINAL"
    
    # Simulate minor voltage fluctuations
    VOLTAGE=$(( 395 + RANDOM % 10 ))
    
    sleep 2
done
