# Window Buttons Applet

This is a Plasma 6 applet that shows window buttons in your panels. This plasmoid is coming from [Latte land](https://phabricator.kde.org/source/latte-dock/repository/master/) but it can also support Plasma panels.

<p align="center">
<img src="https://i.imgur.com/4FItfte.gif" width="580"><br/>
<i>slide in/out animation</i>
</p>

<p align="center">
<img src="https://i.imgur.com/70qeMME.png" width="580"><br/>
<i>Breeze decoration</i>
</p>

<p align="center">
<img src="https://i.imgur.com/uEen6P0.png" width="580"><br/>
<i>BreezeEnhanced decoration</i>
</p>

<p align="center">
<img src="https://i.imgur.com/Zz20RXC.png" width="580"><br/>
<i>Settings window</i>
</p>

# Requires

- Qt >= 6.6 (including Qt5Compat.GraphicalEffects at runtime)
- KDE Frameworks >= 6.0
- Plasma >= 6.3 (libplasma, KDecoration3)

**Qt elements**: Core Gui DBus Qml Quick Widgets

**KF6 elements**: ColorScheme Config CoreAddons I18n Svg extra-cmake-modules

# Install

You can execute `sh install.sh` in the root directory as long as you have installed the previous mentioned development packages. For more details please read [INSTALLATION.md](/INSTALLATION.md)
