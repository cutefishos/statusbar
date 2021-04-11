/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     cutefishos <cutefishos@foxmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "activity.h"

#include <QFile>
#include <QDebug>
#include <QX11Info>
#include <QDirIterator>
#include <QSettings>
#include <QRegularExpression>

#include <NETWM>
#include <KWindowSystem>

Activity::Activity(QObject *parent)
    : QObject(parent)
    , m_cApps(CApplications::self())
{
    onActiveWindowChanged();

    connect(KWindowSystem::self(), &KWindowSystem::activeWindowChanged, this, &Activity::onActiveWindowChanged);
    // connect(KWindowSystem::self(), static_cast<void (KWindowSystem::*)(WId)>(&KWindowSystem::windowChanged),
    //         this, &Activity::onActiveWindowChanged);
}

QString Activity::title() const
{
    return m_title;
}

QString Activity::icon() const
{
    return m_icon;
}

void Activity::close()
{
    NETRootInfo(QX11Info::connection(), NET::CloseWindow).closeWindowRequest(KWindowSystem::activeWindow());
}

void Activity::onActiveWindowChanged()
{
    KWindowInfo info(KWindowSystem::activeWindow(),
                     NET::WMState | NET::WMVisibleName,
                     NET::WM2WindowClass);

    // Skip...
    if (info.windowClassClass() == "cutefish-launcher" ||
        info.windowClassClass() == "cutefish-desktop" ||
        info.windowClassClass() == "cutefish-statusbar") {
        m_title.clear();
        emit titleChanged();
        return;
    }

    m_pid = info.pid();
    m_windowClass = info.windowClassClass().toLower();

    CAppItem *item = m_cApps->matchItem(m_pid);

    if (item) {
        m_title = item->localName;
        emit titleChanged();

        if (m_icon != item->icon) {
            m_icon = item->icon;
            emit iconChanged();
        }

    } else {
        QString title = info.visibleName();
        if (title != m_title) {
            m_title = title;
            emit titleChanged();
            m_icon.clear();
            emit iconChanged();
        }
    }
}
