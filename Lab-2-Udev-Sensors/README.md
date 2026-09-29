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



