
# Linux-ADAS-Projects

# P2 ADAS Camera/Radar Mount Automation via udev Rules
Goal: Automate hardware device detection and environment setup for ADAS sensors (like camera/LiDAR/radar sensors connected via USB/serial) when plugged into an Edge Linux node.

What You Will Build:
Create custom hardware rules that detect when a simulated sensor (or USB flash drive/webcam) is connected. Automate the creation of custom, persistent symlinks (e.g., /dev/adas_camera0), set permissions, and automatically execute a background telemetry logging service.

LPIC-1 Skills Covered:

Linux hardware inspection (udevadm, lsusb, lspci, dmesg).

File permissions (chmod, chown, umask).

Writing custom /etc/udev/rules.d/ rule files.

System event logging (/var/log/syslog, journalctl).

Hands-On Steps:

Plug in a USB peripheral and inspect its vendor and product ID attributes:

Draft a custom udev rule in /etc/udev/rules.d/99-adas-sensor.rules:

Reload rules (sudo udevadm control --reload-rules) and trigger a connection to confirm that /dev/adas_radar0 is dynamically generated and logged.
