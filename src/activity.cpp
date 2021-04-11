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

    if (!matchInfo()) {
        QString title = info.visibleName();
        if (title != m_title) {
            m_title = title;
            emit titleChanged();
            m_icon.clear();
            emit iconChanged();
        }
    }
}

bool Activity::matchInfo()
{
    QString command = commandFromPid(m_pid);

    // TODO: optimization
    QDirIterator it("/usr/share/applications", { "*.desktop" },
                    QDir::NoFilter, QDirIterator::Subdirectories);

    while (it.hasNext()) {
        const QString &filePath = it.next();

        QSettings desktop(filePath, QSettings::IniFormat);
        desktop.setIniCodec("UTF-8");
        desktop.beginGroup("Desktop Entry");

        if (desktop.value("NoDisplay").toBool() ||
            desktop.value("Hidden").toBool()) {
            continue;
        }

        QString exec = desktop.value("Exec").toString();
        exec.remove(QRegularExpression("%."));
        exec.remove(QRegularExpression("^\""));
        exec = exec.simplified();

        if (command == exec) {
            QString name = desktop.value(QString("Name[%1]").arg(QLocale::system().name())).toString();
            if (name.isEmpty())
                name = desktop.value("Name").toString();

            m_title = name;
            emit titleChanged();

            m_icon = desktop.value("Icon").toString();
            emit iconChanged();

            return true;
        }
    }

    return false;
}

QString Activity::commandFromPid(quint32 pid)
{
    QFile file(QString("/proc/%1/cmdline").arg(pid));

    if (file.open(QIODevice::ReadOnly)) {
        QByteArray cmd = file.readAll();

        // ref: https://github.com/KDE/kcoreaddons/blob/230c98aa7e01f9e36a9c2776f3633182e6778002/src/lib/util/kprocesslist_unix.cpp#L137
        if (!cmd.isEmpty()) {
            // extract non-truncated name from cmdline
            int zeroIndex = cmd.indexOf('\0');
            int processNameStart = cmd.lastIndexOf('/', zeroIndex);
            if (processNameStart == -1) {
                processNameStart = 0;
            } else {
                processNameStart++;
            }

            QString name = QString::fromLocal8Bit(cmd.mid(processNameStart, zeroIndex - processNameStart));

            cmd.replace('\0', ' ');
            QString command = QString::fromLocal8Bit(cmd).trimmed();
            return name;
        }
    }

    return QString();
}
