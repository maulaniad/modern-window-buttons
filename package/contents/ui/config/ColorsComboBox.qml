/*
*  Copyright 2018 Michail Vourlakos <mvourlakos@gmail.com>
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

import org.kde.kirigami as Kirigami

QQC2.ComboBox {
    id: combobox

    valueRole: "file"

    onActivated: function(index) {
        root.selectedScheme = valueAt(index);
    }

    //! MenuItem, because the desktop style shows the popup as a Menu
    delegate: QQC2.MenuItem {
        id: colorDelegate
        text: model.display
        highlighted: combobox.highlightedIndex === index

        required property int index
        required property var model

        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            //! two overlapping squares: background and text color of the scheme
            Item {
                Layout.preferredWidth: Kirigami.Units.iconSizes.small * 1.25
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                opacity: (colorDelegate.model.file === "kdeglobals" || colorDelegate.model.file === "_plasmatheme_") ? 0 : 1

                Rectangle {
                    width: Kirigami.Units.iconSizes.small * 0.75
                    height: width
                    color: colorDelegate.model.backgroundColor
                    border.width: 1
                    border.color: Kirigami.Theme.textColor

                    Rectangle {
                        x: parent.width / 2
                        y: parent.height / 2
                        width: parent.width
                        height: parent.height
                        color: colorDelegate.model.textColor
                        border.width: parent.border.width
                        border.color: parent.border.color
                    }
                }
            }

            QQC2.Label {
                Layout.fillWidth: true
                text: colorDelegate.model.display
                color: colorDelegate.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                elide: Text.ElideRight
            }
        }
    }
}
