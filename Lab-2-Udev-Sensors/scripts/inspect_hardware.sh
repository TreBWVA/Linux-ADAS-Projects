#!/usr/bin/env bash
# ==============================================================================
# Script: inspect_hardware.sh
# Description: LPIC-1 utility script to query hardware attributes via udevadm
#              and verify ADAS device symlink status.
# ==============================================================================

set -euo pipefail

TARGET_DEV="${1:-/dev/ttyADAS0}"
SYMLINK_DEV="/dev/adas_radar_front"

echo "================================================================="
echo "        LPIC-1 Hardware & udev Inspection Utility"
echo "================================================================="
echo "Target Device: $TARGET_DEV"
echo ""

# 1. Verify target device exists in filesystem
if [ ! -e "$TARGET_DEV" ]; then
    echo "[ERROR] Device node '$TARGET_DEV' does not exist."
    echo "        Did you run './scripts/setup_simulated_radar.sh' first?"
    exit 1
fi

# 2. Check for udev symlink creation
echo "--- [1] Checking Deterministic udev Symlink Status ---"
if [ -L "$SYMLINK_DEV" ]; then
    SYMLINK_TARGET=$(readlink -f "$SYMLINK_DEV")
    echo "[SUCCESS] Symlink '$SYMLINK_DEV' active!"
    echo "          Pointing directly to -> $SYMLINK_TARGET"
    ls -la "$SYMLINK_DEV"
else
    echo "[WARNING] Symlink '$SYMLINK_DEV' NOT found."
    echo "          Verify '/etc/udev/rules.d/99-rivian-adas-sensors.rules' is installed."
fi
echo ""

# 3. Query device attributes using udevadm (LPIC-1 Exam Core Command)
echo "--- [2] udevadm Device Environment Properties ---"
udevadm info --query=property --name="$TARGET_DEV" | grep -E "DEVNAME|SUBSYSTEM|DEVPATH|MAJOR|MINOR|USEC_INITIALIZED" || true
echo ""

# 4. Display sysfs parent attribute walk (for drafting custom udev rules)
echo "--- [3] Sysfs Hardware Attribute Walk (First 15 Lines) ---"
echo "Useful key-value pairs for matching in /etc/udev/rules.d/:"
echo "-----------------------------------------------------------------"
udevadm info --attribute-walk --name="$TARGET_DEV" | head -n 20
echo "-----------------------------------------------------------------"

# 5. Read sample sensor stream output if device is ready
if [ -L "$SYMLINK_DEV" ] || [ -c "$TARGET_DEV" ]; then
    ACTIVE_NODE="${SYMLINK_DEV:-$TARGET_DEV}"
    echo ""
    echo "--- [4] Sample Data Readout from $ACTIVE_NODE ---"
    echo "Reading 3 sample radar frames (Press Ctrl+C if hanging)..."
    timeout 3s head -n 3 "$ACTIVE_NODE" || echo "[INFO] Stream read timed out or complete."
fi

echo ""
echo "================================================================="
