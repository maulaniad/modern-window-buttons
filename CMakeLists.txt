cmake_minimum_required(VERSION 3.16 FATAL_ERROR)
project(applet_windowbuttons)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(VERSION 0.13.0)
set(AUTHOR "Michail Vourlakos")
set(EMAIL "mvourlakos@gmail.com")

set(QT_MIN_VERSION "6.6.0")
set(KF6_MIN_VERSION "6.0.0")
set(KDECORATION3_MIN_VERSION "6.3.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

# legacy code base: allow implicit const char* <-> QString conversions
remove_definitions(
    -DQT_NO_CAST_FROM_ASCII
    -DQT_NO_CAST_TO_ASCII
    -DQT_NO_CAST_FROM_BYTEARRAY
    -DQT_USE_QSTRINGBUILDER
)

find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Core Gui DBus Qml Quick Widgets)
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS ColorScheme Config CoreAddons I18n Svg)
find_package(Plasma REQUIRED)
find_package(KDecoration3 ${KDECORATION3_MIN_VERSION} REQUIRED)

add_subdirectory(libappletdecoration)
plasma_install_package(package org.kde.windowbuttons)
