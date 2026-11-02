#!/bin/bash
# Build and install the Window Buttons applet (Plasma 6, Qt 6, KDecoration3).
set -euo pipefail

cd "$(dirname "$0")"

cmake -B build -S . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -Wno-dev
cmake --build build -j"$(nproc)"

# Remove files left by older versions (or other forks) so stale QML/plugins
# can't shadow the new ones.
QML_DIR="$(qtpaths6 --query QT_INSTALL_QML 2>/dev/null || qmake6 -query QT_INSTALL_QML)"
OLD_PLUGIN_DIR="$QML_DIR/org/kde/appletdecoration"
OLD_PACKAGE_DIR="/usr/share/plasma/plasmoids/org.kde.windowbuttons"

for dir in "$OLD_PLUGIN_DIR" "$OLD_PACKAGE_DIR"; do
    if [ -d "$dir" ]; then
        echo "Removing previous install: $dir"
        sudo rm -r -- "$dir"
    fi
done

sudo cmake --install build

echo
echo "Installed. Restart Plasma to load it:"
echo "    systemctl --user restart plasma-plasmashell"
