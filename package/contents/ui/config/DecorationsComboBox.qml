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

QQC2.ComboBox {
    id: combobox

    textRole: "text"
    model: []

    onActivated: function(index) {
        const entry = model[index];
        root.useCurrent = (index === 0);
        root.selectedPlugin = entry.plugin;
        root.selectedTheme = entry.theme;
    }

    //! "Current" first, then all decorations sorted by their visible name
    function feedDecorations() {
        let list = [];
        for (let i = 0; i < decorations.count; ++i) {
            const d = decorations.get(i);
            list.push({ text: d.display, plugin: d.plugin, theme: d.theme });
        }
        list.sort(function(a, b) { return a.text.localeCompare(b.text); });
        list.unshift({ text: i18nc("the decoration KWin currently uses", "Current"), plugin: "", theme: "" });

        model = list;

        let idx = 0;
        if (!root.useCurrent) {
            for (let j = 1; j < list.length; ++j) {
                if (list[j].plugin === root.currentPlugin && list[j].theme === root.currentTheme) {
                    idx = j;
                    break;
                }
            }
        }
        currentIndex = idx;
    }

    Component.onCompleted: feedDecorations()
}
