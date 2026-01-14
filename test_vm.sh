#!/bin/bash
# SPDX-FileCopyrightText: 2025 JPShag
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Build and test script for netprivacy module

set -e

echo "=== NetPrivacy Build Script ==="

# Detect distro
if [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
else
    DISTRO="unknown"
fi

echo "Distro: $DISTRO"

# Install deps
case $DISTRO in
    arch)
        sudo pacman -Sy --noconfirm --needed cmake extra-cmake-modules qt6-base qt6-declarative gcc make calamares
        ;;
    debian)
        sudo apt-get update
        sudo apt-get install -y cmake extra-cmake-modules build-essential qt6-base-dev qt6-declarative-dev libxkbcommon-dev calamares
        ;;
    fedora)
        sudo dnf install -y cmake extra-cmake-modules gcc-c++ make qt6-qtbase-devel qt6-qtdeclarative-devel calamares calamares-devel
        ;;
esac

# Build
rm -rf build
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

echo ""
echo "=== Installing ==="
sudo make install

# Verify
INSTALL_PATH="/usr/lib/calamares/modules/netprivacy"
if [ -d "$INSTALL_PATH" ]; then
    echo "Installed to: $INSTALL_PATH"
    ls -la "$INSTALL_PATH"
fi

# Add to settings.conf
SETTINGS="/etc/calamares/settings.conf"
if [ -f "$SETTINGS" ] && ! grep -q "netprivacy" "$SETTINGS"; then
    echo ""
    echo "Add 'netprivacy' to $SETTINGS manually after 'locale' in the sequence."
fi

echo ""
echo "=== Done ==="
echo "Run: sudo calamares -d"
echo ""
read -p "Run now? (y/N): " RUN
if [[ "$RUN" == "y" ]]; then
    mkdir -p /tmp/calamares-root
    sudo calamares -d
fi
