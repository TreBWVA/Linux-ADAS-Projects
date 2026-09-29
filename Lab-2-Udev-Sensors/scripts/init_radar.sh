#!/usr/bin/env bash
# Hardware event handler executed by udev daemon upon sensor match

LOG_FILE="/var/log/adas_sensor_events.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Ensure directory exists
mkdir -p "$(dirname "$LOG_FILE")"

echo "[$TIMESTAMP] [udev EVENT] ADAS Radar Hardware Connected." >> "$LOG_FILE"

# Apply serial line parameters if device node is ready
if [ -c /dev/adas_radar_front ]; then
    stty -F /dev/adas_radar_front 115200 raw -echo 2>> "$LOG_FILE"
    echo "[$TIMESTAMP] [udev SUCCESS] Configured /dev/adas_radar_front to 115200 baud." >> "$LOG_FILE"
fi
