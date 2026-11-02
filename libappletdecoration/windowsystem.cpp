/*
 * Copyright 2018  Michail Vourlakos <mvourlakos@gmail.com>
 *
 * This file is part of the libappletdecoration library
 *
 * Latte-Dock is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * Latte-Dock is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "windowsystem.h"

#include <KConfigGroup>
#include <KSharedConfig>

#include <QDBusMessage>
#include <QDBusConnection>

namespace Decoration {
namespace Applet {


WindowSystem::WindowSystem(QObject *parent)
    : QObject(parent)
{
}

WindowSystem::~WindowSystem() = default;

bool WindowSystem::kwin_disabledMaximizedBorders() const
{
    const KConfigGroup windows(KSharedConfig::openConfig(QStringLiteral("kwinrc"), KConfig::NoGlobals), QStringLiteral("Windows"));
    return windows.readEntry("BorderlessMaximizedWindows", false);
}

void WindowSystem::setDisabledMaximizedBorders(bool disable)
{
    if (kwin_disabledMaximizedBorders() == disable) {
        return;
    }

    auto config = KSharedConfig::openConfig(QStringLiteral("kwinrc"), KConfig::NoGlobals);
    KConfigGroup windows(config, QStringLiteral("Windows"));
    windows.writeEntry("BorderlessMaximizedWindows", disable, KConfig::Notify);
    config->sync();

    //! ask all KWin instances to reload their configuration
    QDBusMessage message = QDBusMessage::createSignal(QStringLiteral("/KWin"),
                                                      QStringLiteral("org.kde.KWin"),
                                                      QStringLiteral("reloadConfig"));
    QDBusConnection::sessionBus().send(message);
}

}
}
