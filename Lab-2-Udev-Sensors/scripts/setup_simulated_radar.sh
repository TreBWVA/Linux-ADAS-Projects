
#!/usr/bin/env bash
# ==============================================================================
# Script: setup_simulated_radar.sh
# Description: Spawns a virtual ADAS radar serial device node using socat
#              and streams mock target detection frames.
# ==============================================================================

set -euo pipefail

DEV_NODE="/dev/ttyADAS0"
SIM_FEED="/tmp/ttyRadarSim"
LOG_FILE="/tmp/radar_feed.log"

echo "==> Setting up simulated ADAS Radar Hardware..."

# 1. Clean up any existing virtual radar background processes
pkill -f "socat.*ttyADAS0" || true
rm -f "$DEV_NODE" "$SIM_FEED"

# 2. Spawn virtual serial device pair in background via socat
# - pty 1: Mounted as system device node /dev/ttyADAS0
# - pty 2: Linked to /tmp/ttyRadarSim to write mock radar data into
socat -d -d pty,raw,echo=0,link="$SIM_FEED" pty,raw,echo=0,link="$DEV_NODE" > "$LOG_FILE" 2>&1 &
SOCAT_PID=$!

# Wait for device nodes to register in filesystem
sleep 1

if [ -c "$DEV_NODE" ]; then
    echo "[SUCCESS] Virtual ADAS Radar device created at: $DEV_NODE"
    echo "[INFO] Socat PID: $SOCAT_PID"
else
    echo "[ERROR] Failed to create device node $DEV_NODE. Is socat installed?"
    exit 1
fi

# 3. Ensure proper baseline file permissions
sudo chmod 0666 "$DEV_NODE" "$SIM_FEED"

# 4. Trigger udev engine to process hardware addition event
echo "==> Triggering udev device event for subsystem 'tty'..."
sudo udevadm trigger --subsystem-match=tty --action=add

# 5. Background task: Stream mock NMEA/Radar target frame payloads into sensor feed
(
    while [ -c "$SIM_FEED" ]; do
        TIMESTAMP=$(date "+%H%M%S")
        # Simulated radar detection payload: $RADAR,<Target_ID>,<Distance_m>,<Velocity_m_s>*Checksum
        echo "\$RADAR,T01,24.5,+12.2*${TIMESTAMP}" > "$SIM_FEED"
        sleep 0.5
    done
) &
STREAM_PID=$!

echo "[SUCCESS] Mock radar data stream active (PID: $STREAM_PID)."
echo "          Run './scripts/inspect_hardware.sh' to verify udev symlink."
