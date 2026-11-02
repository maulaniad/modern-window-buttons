set(appletdecoration_SRCS
    appletdecorationplugin.cpp
    auroraetheme.cpp
    buttonsmodel.cpp
    commontools.cpp
    decorationsmodel.cpp
    decorationpalette.cpp
    environment.cpp
    padding.cpp
    previewbutton.cpp
    previewbridge.cpp
    previewclient.cpp
    previewsettings.cpp
    previewshareddecoration.cpp
    schemecolors.cpp
    schemesmodel.cpp
    themeextended.cpp
    types.cpp
    windowsystem.cpp
)

add_library(appletdecorationplugin MODULE ${appletdecoration_SRCS})
# keep the historical file name so an upgrade replaces the old plugin
set_target_properties(appletdecorationplugin PROPERTIES PREFIX "lib")

target_link_libraries(appletdecorationplugin
    Qt6::Core
    Qt6::DBus
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Widgets
    KF6::ColorScheme
    KF6::ConfigCore
    KF6::CoreAddons
    KF6::I18n
    KF6::Svg
    Plasma::Plasma
    KDecoration3::KDecoration
    KDecoration3::KDecoration3Private
)

install(TARGETS appletdecorationplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/appletdecoration)
install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/appletdecoration)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/appletdecoration)
