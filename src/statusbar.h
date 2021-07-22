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

#ifndef STATUSBAR_H
#define STATUSBAR_H

#include <QQuickView>
#include "activity.h"

class StatusBar : public QQuickView
{
    Q_OBJECT
    Q_PROPERTY(QRect screenRect READ screenRect NOTIFY screenRectChanged)

public:
    explicit StatusBar(QQuickView *parent = nullptr);

    QRect screenRect();

    void setBatteryPercentage(bool enabled);

    void updateGeometry();
    void updateViewStruts();

signals:
    void screenRectChanged();
    void launchPadChanged();

private slots:
    void onPrimaryScreenChanged(QScreen *screen);

private:
    QRect m_screenRect;
    Activity *m_acticity;
};

#endif // STATUSBAR_H
