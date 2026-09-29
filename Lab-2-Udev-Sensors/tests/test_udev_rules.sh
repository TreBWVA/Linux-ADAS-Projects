#!/usr/bin/env bash
# Validates udev rule matching against simulated sysfs device paths

echo "==> Running dry-run udev rule resolution test..."

# Test udev rule execution on virtual or existing tty device node
if [ -e /dev/ttyADAS0 ]; then
    DEVPATH=$(udevadm info --query=path --name=/dev/ttyADAS0)
    
    echo "Testing sysfs path: $DEVPATH"
    udevadm test "$DEVPATH" 2>&1 | grep -E "SYMLINK|RUN"
else
    echo "Notice: /dev/ttyADAS0 not found. Run 'make simulate' first."
fi
