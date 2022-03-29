/*
 * Copyright (C) 2021 - 2022 CutefishOS Team.
 *
 * Author:     Reion Wong <reionwong@gmail.com>
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

#include "backgroundhelper.h"

#include <QApplication>
#include <QDebug>
#include <QPixmap>
#include <QScreen>
#include <QRgb>

BackgroundHelper::BackgroundHelper(QObject *parent)
    : QObject(parent)
    , m_statusBarHeight(25 / qApp->devicePixelRatio())
{
}

void BackgroundHelper::setColor(QColor c)
{
    emit newColor(c, c.lightness());
}

void BackgroundHelper::setBackgound(const QString &fileName)
{
    QImage img(fileName);

    QSize screenSize = qApp->primaryScreen()->geometry().size();
    img = img.scaled(screenSize.width(), screenSize.height());
    img = img.copy(QRect(0, 0, screenSize.width(), m_statusBarHeight));

    QSize size(img.size());
    img = img.scaledToWidth(size.width() * 0.8);
    size = img.size();

    long long sumR = 0, sumG = 0, sumB = 0;
    int measureArea = size.width() * size.height();

    for (int y = 0; y < size.height(); ++y) {
        QRgb *line = (QRgb *)img.scanLine(y);

        for (int x = 0; x < size.width(); ++x) {
            sumR += qRed(line[x]);
            sumG += qGreen(line[x]);
            sumB += qBlue(line[x]);
        }
    }

    sumR /= measureArea;
    sumG /= measureArea;
    sumB /= measureArea;

    QColor c = QColor(sumR, sumG, sumB);

    emit newColor(c, c.lightness());
}
