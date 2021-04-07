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

#include "statusbar.h"
#include "processprovider.h"

#include <QQmlEngine>
#include <QQmlContext>

#include <QApplication>
#include <QScreen>

#include <NETWM>
#include <KWindowSystem>
#include <KWindowEffects>

StatusBar::StatusBar(QQuickView *parent)
    : QQuickView(parent)
    , m_acticity(new Activity)
{
    setFlags(Qt::FramelessWindowHint | Qt::WindowDoesNotAcceptFocus);
    setColor(Qt::transparent);

    KWindowSystem::setOnDesktop(winId(), NET::OnAllDesktops);
    KWindowSystem::setType(winId(), NET::Dock);
    KWindowEffects::slideWindow(winId(), KWindowEffects::TopEdge);

    engine()->rootContext()->setContextProperty("acticity", m_acticity);
    engine()->rootContext()->setContextProperty("process", new ProcessProvider);

    setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    setResizeMode(QQuickView::SizeRootObjectToView);
    setScreen(qApp->primaryScreen());
    updateGeometry();
    setVisible(true);

    connect(qApp->primaryScreen(), &QScreen::virtualGeometryChanged, this, &StatusBar::updateGeometry);
    connect(qApp->primaryScreen(), &QScreen::geometryChanged, this, &StatusBar::updateGeometry);
}

void StatusBar::updateGeometry()
{
    const QRect rect = qApp->primaryScreen()->geometry();
    QRect windowRect = QRect(rect.x(), rect.y(), rect.width(), 30);
    setGeometry(windowRect);
    updateViewStruts();

    KWindowEffects::enableBlurBehind(winId(), true);
}

void StatusBar::updateViewStruts()
{
    const QRect windowRect = geometry();
    NETExtendedStrut strut;

    strut.top_width = windowRect.height();
    strut.top_start = x();
    strut.top_end = x() + windowRect.width();

    KWindowSystem::setExtendedStrut(winId(),
                                 strut.left_width,
                                 strut.left_start,
                                 strut.left_end,
                                 strut.right_width,
                                 strut.right_start,
                                 strut.right_end,
                                 strut.top_width,
                                 strut.top_start,
                                 strut.top_end,
                                 strut.bottom_width,
                                 strut.bottom_start,
                                 strut.bottom_end);
}
