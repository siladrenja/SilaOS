#!/usr/bin/env bash
set -e

echo "=============================================="
echo "       Guided NixOS Host Installer           "
echo "=============================================="

# 0. Initialize a temporary Git repo so Flakes sees all files cleanly
if [ ! -d ".git" ]; then
    git init >/dev/null 2>&1 || true
    git config user.name "NixOS Installer" >/dev/null 2>&1 || true
    git config user.email "installer@nixos.local" >/dev/null 2>&1 || true
    git add . >/dev/null 2>&1 || true
fi

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

# 3. Partition and format drive using pre-installed Disko binary
echo "==> Partitioning drive with Disko..."
if command -v disko &>/dev/null; then
    disko --mode disko "$HOST_DIR/disko.nix"
else
    nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko "$HOST_DIR/disko.nix"
fi

# 4. Generate hardware configuration
echo "==> Generating hardware configuration..."
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"

# Stage hardware-configuration.nix so git/flakes registers the new file
git add "$HOST_DIR/hardware-configuration.nix" >/dev/null 2>&1 || true

# 5. Copy full repository to target drive /mnt/etc/nixos
echo "==> Copying NixOS repository to /etc/nixos..."
mkdir -p /mnt/etc/nixos
cp -a ./. /mnt/etc/nixos/

# Initialize Git in /mnt/etc/nixos so git pull / rebuild alias works post-reboot
cd /mnt/etc/nixos
git init >/dev/null 2>&1 || true
git add . >/dev/null 2>&1 || true

# 6. Install system using explicit 'path:' flake reference
echo "==> Installing NixOS for host '$HOSTNAME'..."
nixos-install --flake "path:/mnt/etc/nixos#$HOSTNAME"

echo ""
echo "=============================================="
echo " Installation complete!"
echo "=============================================="
read -p "Reboot now? (y/N): " REBOOT_CONFIRM
if [[ "$REBOOT_CONFIRM" == "y" || "$REBOOT_CONFIRM" == "Y" ]]; then
    reboot
fi