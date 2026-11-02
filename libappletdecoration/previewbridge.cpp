/*
 * Copyright 2014  Martin Gräßlin <mgraesslin@kde.org>
 *           2018  Michail Vourlakos <mvourlakos@gmail.org>
 *
 *  This file is part of the libappletdecoration library
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "previewbridge.h"

#include "previewbutton.h"
#include "previewclient.h"
#include "previewsettings.h"

#include <KDecoration3/DecoratedWindow>
#include <KDecoration3/Decoration>

#include <KDirWatch>
#include <KPluginFactory>
#include <KPluginMetaData>

#include <QDebug>
#include <QStandardPaths>

namespace Decoration {
namespace Applet {

static const QString s_pluginName = QStringLiteral("org.kde.kdecoration3");
static const QString s_breezerc = QStringLiteral("breezerc");

PreviewBridge::PreviewBridge(QObject *parent)
    : KDecoration3::DecorationBridge(parent)
    , m_lastCreatedClient(nullptr)
    , m_lastCreatedSettings(nullptr)
    , m_valid(false)
{
    connect(this, &PreviewBridge::pluginChanged, this, &PreviewBridge::createFactory);

    const auto breezeRc = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) +
                          QLatin1Char('/') + s_breezerc;

    KDirWatch::self()->addFile(breezeRc);

    connect(KDirWatch::self(), &KDirWatch::dirty, this, &PreviewBridge::settingsFileChanged);
    connect(KDirWatch::self(), &KDirWatch::created, this, &PreviewBridge::settingsFileChanged);
}

PreviewBridge::~PreviewBridge() = default;

std::unique_ptr<KDecoration3::DecoratedWindowPrivate> PreviewBridge::createClient(KDecoration3::DecoratedWindow *client, KDecoration3::Decoration *decoration)
{
    auto ptr = std::unique_ptr<PreviewClient>(new PreviewClient(client, decoration));
    m_lastCreatedClient = ptr.get();
    return ptr;
}

std::unique_ptr<KDecoration3::DecorationSettingsPrivate> PreviewBridge::settings(KDecoration3::DecorationSettings *parent)
{
    auto ptr = std::unique_ptr<PreviewSettings>(new PreviewSettings(parent));
    m_lastCreatedSettings = ptr.get();
    return ptr;
}

void PreviewBridge::registerButton(PreviewButtonItem *button)
{
    m_previewButtons.append(button);
}

void PreviewBridge::unregisterButton(PreviewButtonItem *button)
{
    m_previewButtons.removeAll(button);
}

void PreviewBridge::setPlugin(const QString &plugin)
{
    if (m_plugin == plugin) {
        return;
    }

    m_plugin = plugin;
    qDebug() << "Plugin changed to: " << m_plugin;
    Q_EMIT pluginChanged();
}

QString PreviewBridge::theme() const
{
    return m_theme;
}

void PreviewBridge::setTheme(const QString &theme)
{
    if (m_theme == theme) {
        return;
    }

    m_theme = theme;
    Q_EMIT themeChanged();
}

QString PreviewBridge::plugin() const
{
    return m_plugin;
}

void PreviewBridge::createFactory()
{
    m_factory.clear();

    if (m_plugin.isNull()) {
        setValid(false);
        qDebug() << "Plugin not set";
        return;
    }

    const KPluginMetaData metaData = KPluginMetaData::findPluginById(s_pluginName, m_plugin);

    if (!metaData.isValid()) {
        setValid(false);
        qDebug() << "Decoration plugin not found:" << m_plugin;
        return;
    }

    m_factory = KPluginFactory::loadFactory(metaData).plugin;
    setValid(!m_factory.isNull());
    reconfigure();
}

bool PreviewBridge::isValid() const
{
    return m_valid;
}

void PreviewBridge::setValid(bool valid)
{
    if (m_valid == valid) {
        return;
    }

    m_valid = valid;
    Q_EMIT validChanged();
}

KDecoration3::Decoration *PreviewBridge::createDecoration(QObject *parent)
{
    if (!m_valid) {
        return nullptr;
    }

    QVariantMap args({ {QStringLiteral("bridge"), QVariant::fromValue(this)} });

    if (!m_theme.isNull()) {
        args.insert(QStringLiteral("theme"), m_theme);
    }

    return m_factory->create<KDecoration3::Decoration>(parent, QVariantList({args}));
}

KDecoration3::DecorationButton *PreviewBridge::createButton(KDecoration3::Decoration *decoration, KDecoration3::DecorationButtonType type, QObject *parent)
{
    if (!m_valid) {
        return nullptr;
    }

    return m_factory->create<KDecoration3::DecorationButton>(parent, QVariantList({QVariant::fromValue(type), QVariant::fromValue(decoration)}));
}

void PreviewBridge::settingsFileChanged(const QString &filename)
{
    if (!filename.endsWith(s_breezerc)) {
        return;
    }

    reconfigure();
}

void PreviewBridge::reconfigure()
{
    if (m_lastCreatedSettings) {
        Q_EMIT m_lastCreatedSettings->decorationSettings()->reconfigured();
    }
}

BridgeItem::BridgeItem(QObject *parent)
    : QObject(parent)
    , m_bridge(new PreviewBridge())
{
    connect(m_bridge, &PreviewBridge::themeChanged, this, &BridgeItem::themeChanged);
    connect(m_bridge, &PreviewBridge::pluginChanged, this, &BridgeItem::pluginChanged);
    connect(m_bridge, &PreviewBridge::validChanged, this, &BridgeItem::validChanged);
}

BridgeItem::~BridgeItem()
{
    m_bridge->deleteLater();
}

}
}
