Installation
============

## Building from Source
The provided `install.sh` script will build everything and install it for you. Before running the installation script you have to install the dependencies needed for compiling.

### Build Dependencies

This version targets **Plasma 6.3 or newer** (Qt 6, KDE Frameworks 6, KDecoration3).

- Fedora:
```
sudo dnf install gcc-c++ extra-cmake-modules qt6-qtdeclarative-devel qt6-qt5compat \
    kf6-kconfig-devel kf6-kcoreaddons-devel kf6-ki18n-devel kf6-kcolorscheme-devel kf6-ksvg-devel \
    libplasma-devel kdecoration-devel
```
- Arch:
```
sudo pacman -S gcc cmake extra-cmake-modules qt6-declarative qt6-5compat \
    kconfig kcoreaddons ki18n kcolorscheme ksvg libplasma kdecoration
```

### Building and Installing
Once you have installed the dependencies listed above you can execute the build and install script:

```
sh install.sh
systemctl --user restart plasma-plasmashell
```

`install.sh` asks for `sudo` to install into `/usr` and first removes an older copy of the applet, so stale files from Plasma 5 builds or other forks can't shadow the new ones. `uninstall.sh` removes what the last build installed.
