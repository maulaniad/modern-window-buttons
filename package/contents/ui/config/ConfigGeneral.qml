/*
*  Copyright 2018  Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of applet-window-buttons
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

import org.kde.appletdecoration as AppletDecoration

KCM.SimpleKCM {
    id: root

    property alias cfg_useCurrentDecoration: root.useCurrent
    property alias cfg_selectedPlugin: root.selectedPlugin
    property alias cfg_selectedScheme: root.selectedScheme
    property alias cfg_selectedTheme: root.selectedTheme
    property alias cfg_buttons: root.currentButtons
    property alias cfg_buttonSizePercentage: buttonSizeSpn.value
    property alias cfg_visibility: root.visibility
    property alias cfg_filterByScreen: byScreenChk.checked
    property alias cfg_hiddenState: root.hiddenState
    property alias cfg_inactiveStateEnabled: inactiveChk.checked
    property alias cfg_useDecorationMetrics: decorationMetricsChk.checked
    property alias cfg_spacing: spacingSpn.value
    property alias cfg_lengthFirstMargin: lengthFirstSpn.value
    property alias cfg_lengthLastMargin: lengthLastSpn.value
    property alias cfg_lengthMarginsLock: lockBtn.checked

    // read only, written by the applet itself
    property int cfg_formFactor: PlasmaCore.Types.Horizontal
    property int cfg_containmentType: AppletDecoration.Types.Plasma

    // Plasma also passes the default of every key
    property var cfg_useCurrentDecorationDefault
    property var cfg_selectedPluginDefault
    property var cfg_selectedSchemeDefault
    property var cfg_selectedThemeDefault
    property var cfg_buttonsDefault
    property var cfg_buttonSizePercentageDefault
    property var cfg_visibilityDefault
    property var cfg_filterByScreenDefault
    property var cfg_hiddenStateDefault
    property var cfg_inactiveStateEnabledDefault
    property var cfg_useDecorationMetricsDefault
    property var cfg_spacingDefault
    property var cfg_lengthFirstMarginDefault
    property var cfg_lengthLastMarginDefault
    property var cfg_lengthMarginsLockDefault
    property var cfg_formFactorDefault
    property var cfg_containmentTypeDefault

    // used as bridge to communicate properly between configuration and ui
    property bool useCurrent
    property int hiddenState
    property int visibility
    property string selectedPlugin
    property string selectedScheme
    property string selectedTheme
    property string currentButtons

    // used from the ui
    readonly property bool selectedDecorationExists: decorations.decorationExists(root.selectedPlugin, root.selectedTheme)
    readonly property bool isHorizontal: cfg_formFactor !== PlasmaCore.Types.Vertical

    property string currentPlugin: root.useCurrent || !selectedDecorationExists ? decorations.currentPlugin : root.selectedPlugin
    property string currentTheme: root.useCurrent || !selectedDecorationExists ? decorations.currentTheme : root.selectedTheme

    ///START Decoration Items
    AppletDecoration.Bridge {
        id: bridgeItem
        plugin: root.currentPlugin
        theme: root.currentTheme
    }

    AppletDecoration.Settings {
        id: settingsItem
        bridge: bridgeItem.bridge
        borderSizesIndex: 0
    }

    AppletDecoration.SharedDecoration {
        id: sharedDecorationItem
        bridge: bridgeItem.bridge
        settings: settingsItem
    }

    AppletDecoration.AuroraeTheme {
        id: auroraeThemeEngine
        theme: isEnabled ? root.currentTheme : ""

        readonly property bool isEnabled: decorations.isAurorae(root.currentPlugin, root.currentTheme)
    }

    AppletDecoration.DecorationsModel {
        id: decorations
    }

    AppletDecoration.ColorsModel {
        id: colorsModel
    }

    AppletDecoration.PlasmaThemeExtended {
        id: plasmaThemeExtended

        readonly property bool isActive: root.selectedScheme === "_plasmatheme_"
    }
    ///END Decoration Items

    Kirigami.FormLayout {
        id: form

        DecorationsComboBox {
            id: decorationCmb
            Kirigami.FormData.label: i18n("Decoration:")
            Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        }

        ColorsComboBox {
            id: colorsCmbBox
            Kirigami.FormData.label: i18n("Colors:")
            Layout.minimumWidth: Kirigami.Units.gridUnit * 14
            visible: !auroraeThemeEngine.isEnabled

            model: colorsModel
            textRole: "display"

            Component.onCompleted: {
                currentIndex = colorsModel.indexOf(root.selectedScheme);
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18n("Buttons:")
            spacing: Kirigami.Units.smallSpacing

            OrderableListView {
                id: activeButtons
                itemWidth: 38
                itemHeight: 38
                buttonsStr: root.currentButtons
                orientation: ListView.Horizontal
                color: !auroraeThemeEngine.isEnabled ? schemesBackgroundColor : auroraeThemeEngine.titleBackgroundColor

                buttonSize: buttonSizeSpn.value
                buttonsFirstMargin: lengthFirstSpn.value
                buttonsLastMargin: lengthLastSpn.value
                buttonsSpacing: spacingSpn.value

                readonly property color schemesBackgroundColor: plasmaThemeExtended.isActive ?
                                                                    plasmaThemeExtended.colors.backgroundColor :
                                                                    colorsModel.backgroundOf(colorsCmbBox.currentIndex)
            }

            QQC2.Label {
                Layout.fillWidth: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 20
                text: i18n("Press and hold a button, then drag it to reorder. Buttons after the separator are hidden.")
                font: Kirigami.Theme.smallFont
                opacity: 0.7
                wrapMode: Text.Wrap
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ButtonGroup { id: visibilityGroup }

        QQC2.RadioButton {
            Kirigami.FormData.label: i18n("Show:")
            text: i18n("Always visible")
            checked: root.visibility === AppletDecoration.Types.AlwaysVisible
            QQC2.ButtonGroup.group: visibilityGroup
            onToggled: if (checked) root.visibility = AppletDecoration.Types.AlwaysVisible
        }
        QQC2.RadioButton {
            text: i18n("Active window is present")
            checked: root.visibility === AppletDecoration.Types.ActiveWindow
            QQC2.ButtonGroup.group: visibilityGroup
            onToggled: if (checked) root.visibility = AppletDecoration.Types.ActiveWindow
        }
        QQC2.RadioButton {
            text: root.cfg_containmentType === AppletDecoration.Types.Latte ?
                      i18n("Last active window is maximized") : i18n("Active window is maximized")
            checked: root.visibility === AppletDecoration.Types.ActiveMaximizedWindow
            QQC2.ButtonGroup.group: visibilityGroup
            onToggled: if (checked) root.visibility = AppletDecoration.Types.ActiveMaximizedWindow
        }
        QQC2.RadioButton {
            text: i18n("At least one window is shown")
            checked: root.visibility === AppletDecoration.Types.ShownWindowExists
            QQC2.ButtonGroup.group: visibilityGroup
            onToggled: if (checked) root.visibility = AppletDecoration.Types.ShownWindowExists
        }

        QQC2.ButtonGroup { id: hiddenStateGroup }

        QQC2.RadioButton {
            Kirigami.FormData.label: i18n("When hidden:")
            text: i18n("Slide out")
            enabled: root.visibility !== AppletDecoration.Types.AlwaysVisible
            checked: root.hiddenState === AppletDecoration.Types.SlideOut
            QQC2.ButtonGroup.group: hiddenStateGroup
            onToggled: if (checked) root.hiddenState = AppletDecoration.Types.SlideOut
        }
        QQC2.RadioButton {
            text: i18n("Keep the space empty")
            enabled: root.visibility !== AppletDecoration.Types.AlwaysVisible
            checked: root.hiddenState === AppletDecoration.Types.EmptySpace
            QQC2.ButtonGroup.group: hiddenStateGroup
            onToggled: if (checked) root.hiddenState = AppletDecoration.Types.EmptySpace
        }

        QQC2.CheckBox {
            id: byScreenChk
            Kirigami.FormData.label: i18n("Filters:")
            text: i18n("Only windows on the current screen")
        }

        QQC2.CheckBox {
            id: inactiveChk
            Kirigami.FormData.label: i18n("Appearance:")
            text: i18n("Draw inactive buttons when no window is active")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: decorationMetricsChk
            Kirigami.FormData.label: i18n("Metrics:")
            text: i18n("Use size and spacing from the decoration")
            visible: auroraeThemeEngine.isEnabled
        }

        QQC2.SpinBox {
            id: buttonSizeSpn
            Kirigami.FormData.label: i18n("Size:")
            from: 40
            to: 100
            enabled: !(auroraeThemeEngine.isEnabled && decorationMetricsChk.checked)
            textFromValue: function(value) { return i18nc("percentage", "%1 %", value); }
            valueFromText: function(text) { return parseInt(text); }
        }

        QQC2.SpinBox {
            id: spacingSpn
            Kirigami.FormData.label: i18n("Spacing:")
            from: 0
            to: 24
            enabled: !(auroraeThemeEngine.isEnabled && decorationMetricsChk.checked)
            textFromValue: function(value) { return i18nc("pixels", "%1 px", value); }
            valueFromText: function(text) { return parseInt(text); }
        }

        QQC2.SpinBox {
            id: lengthFirstSpn
            Kirigami.FormData.label: root.isHorizontal ? i18n("Left margin:") : i18n("Top margin:")
            from: 0
            to: 24
            textFromValue: function(value) { return i18nc("pixels", "%1 px", value); }
            valueFromText: function(text) { return parseInt(text); }

            //! valueChanged is emitted before valueModified, so the step of a
            //! user edit is known when valueModified arrives
            property int previousValue: 0
            property int step: 0

            onValueChanged: {
                step = value - previousValue;
                previousValue = value;
            }

            onValueModified: {
                if (lockBtn.checked) {
                    lengthLastSpn.value = Math.max(lengthLastSpn.from, Math.min(lengthLastSpn.to, lengthLastSpn.value + step));
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: root.isHorizontal ? i18n("Right margin:") : i18n("Bottom margin:")
            spacing: Kirigami.Units.smallSpacing

            QQC2.SpinBox {
                id: lengthLastSpn
                from: 0
                to: 24
                enabled: !lockBtn.checked
                textFromValue: function(value) { return i18nc("pixels", "%1 px", value); }
                valueFromText: function(text) { return parseInt(text); }
            }

            QQC2.ToolButton {
                id: lockBtn
                checkable: true
                icon.name: checked ? "object-locked" : "object-unlocked"
                text: i18n("Link margins")
                display: QQC2.AbstractButton.IconOnly
                QQC2.ToolTip.text: checked ? i18n("Margins change together") : i18n("Margins change separately")
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            }
        }
    }
}
