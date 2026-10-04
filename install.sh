#!/usr/bin/env bash
set -e

echo "=============================================="
echo "       Guided NixOS Host Installer           "
echo "=============================================="

# 1. Detect hosts from repository
echo ""
echo "Available hosts in repository:"
hosts=(hosts/*/)
for h in "${hosts[@]}"; do
    echo "  - $(basename "$h")"
done

echo ""
read -p "Select hostname to install: " HOSTNAME

HOST_DIR="./hosts/$HOSTNAME"

if [ ! -d "$HOST_DIR" ]; then
    echo "Error: Host directory '$HOST_DIR' does not exist!"
    exit 1
fi

if [ ! -f "$HOST_DIR/disko.nix" ]; then
    echo "Error: '$HOST_DIR/disko.nix' not found!"
    exit 1
fi

# 2. Extract target drive from disko.nix for user verification
TARGET_DRIVE=$(grep -E 'device\s*=' "$HOST_DIR/disko.nix" | head -n1 | awk -F'"' '{print $2}')

echo ""
echo "----------------------------------------------"
echo " Target Host : $HOSTNAME"
echo " Target Drive: ${TARGET_DRIVE:-Unknown}"
echo "----------------------------------------------"
echo "WARNING: Disko will COMPLETELY ERASE ${TARGET_DRIVE}!"
read -p "Are you sure you want to proceed? (y/N): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

# 3. Partition and format drive
echo "==> Partitioning drive with Disko..."
nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko "$HOST_DIR/disko.nix"

# 4. Generate hardware configuration
echo "==> Generating hardware configuration..."
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"

# 5. Lock flake inputs & install system
echo "==> Locking inputs & installing NixOS for host '$HOSTNAME'..."
nix flake lock
nixos-install --flake .#"$HOSTNAME"

echo ""
echo "=============================================="
echo " Installation complete!"
echo "=============================================="
read -p "Reboot now? (y/N): " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" == "y" || "$REBOOT_CONFIRM" == "Y" ]]; then
    reboot
fi