# Lab 2: ADAS Camera & Radar Hardware Automation via `udev`

## Summary
In automotive platforms like Rivian's Autonomy Compute Module, multimodal sensor suites (forward/corner radars, driver-monitoring cameras, LiDAR) connect via USB, PCIe, or serial buses. When devices hotplug or re-enumerate at boot, the Linux kernel dynamically assigns non-deterministic nodes (e.g., `/dev/ttyUSB0` vs. `/dev/ttyUSB1` or `/dev/video0` vs. `/dev/video1`).

This project implements a system-level **`udev` rule and event-handling pipeline** that:
1. Intercepts kernel hardware events via `sysfs`.
2. Inspects hardware attributes (Vendor IDs, Product IDs, bus paths).
3. Generates **deterministic, persistent device symlinks** (`/dev/adas_radar_front`).
4. Enforces least-privilege POSIX file permissions for non-root ADAS processes.
5. Automatically triggers hardware initialization scripts (e.g., `stty` baud-rate configuration) upon hotplug.

---

## Technical Architecture

```text
┌────────────────────────┐
│  Hardware / Sensor Bus │ (Serial / USB / PTY)
└───────────┬────────────┘
            │ 1. Kernel Hotplug / uevent
            ▼
┌────────────────────────┐
│  Linux Kernel (sysfs)  │ Exposes attributes at /sys/class/tty/...
└───────────┬────────────┘
            │ 2. Match attributes (idVendor, KERNEL, SUBSYSTEM)
            ▼
┌────────────────────────┐
│      udev Daemon       │ Parses /etc/udev/rules.d/99-rivian-adas-sensors.rules
└─────┬────────────┬─────┘
      │            │
      │ 3. Create Symlink            │ 4. RUN += Trigger Script
      ▼                              ▼
┌────────────────────────┐   ┌────────────────────────┐
│ /dev/adas_radar_front  │   │ /usr/local/bin/        │ Sets 115200 baud &
│ -> /dev/ttyADAS0       │   │   init_radar.sh        │ logs system event

---
## **Key Files & Configuration**
## **1. udev Rule Definitions (config/99-rivian-adas-sensors.rules)**
Plaintext


# Front ADAS Radar Sensor (Virtual or Physical ttyADAS device)
# Creates static symlink /dev/adas_radar_front and executes trigger script
SUBSYSTEM=="tty", KERNEL=="ttyADAS*", MODE="0666", SYMLINK+="adas_radar_front", RUN+="/usr/local/bin/init_radar.sh"

# Driver Monitoring System (DMS) USB Camera / FTDI Serial Driver
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0660", GROUP="plugdev", SYMLINK+="adas_camera_dms"
## **2. Event Trigger Script (scripts/init_radar.sh)**
Executed automatically by the udev daemon with root privileges upon hardware match:

Bash


#!/usr/bin/env bash
LOG_FILE="/var/log/adas_sensor_events.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] [udev EVENT] ADAS Radar Hardware Connected." >> "$LOG_FILE"

if [ -c /dev/adas_radar_front ]; then
    stty -F /dev/adas_radar_front 115200 raw -echo
    echo "[$TIMESTAMP] [udev SUCCESS] Configured /dev/adas_radar_front to 115200 baud." >> "$LOG_FILE"
fi
## **Getting Started**
Prerequisites
Linux Environment (Ubuntu/Debian preferred)

Required packages: udev, socat, coreutils

Installation & Execution
Install Rules & Trigger Scripts:

Bash


make install
Copies 99-rivian-adas-sensors.rules to /etc/udev/rules.d/, deploys init_radar.sh to /usr/local/bin/, and reloads udevadm.

Simulate Radar Hardware:

Bash


make simulate
Uses socat to spawn a virtual pseudoterminal /dev/ttyADAS0 and streams mock NMEA-style radar target frames.

Inspect Hardware & Verify Symlink:

Bash


make inspect
Runs inspect_hardware.sh to output device attributes via udevadm info and confirms /dev/adas_radar_front is active.

Clean Up Environment:

Bash


make clean
LPIC-1 Command Reference Covered
Hardware Inspection: udevadm info --attribute-walk --name=/dev/...

Rule Reloading: sudo udevadm control --reload-rules

Event Triggering: sudo udevadm trigger --subsystem-match=tty

Real-time Event Monitoring: sudo udevadm monitor --environment

Dry-Run Rule Testing: udevadm test /sys/class/tty/ttyADAS0

TTY Line Configuration: stty -F /dev/adas_radar_front 115200
└────────────────────────┘   └────────────────────────┘
