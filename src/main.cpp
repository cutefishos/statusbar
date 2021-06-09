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

#include <QApplication>
#include <QTranslator>
#include <QLocale>

#include "statusbar.h"
#include "controlcenterdialog.h"
#include "systemtray/systemtraymodel.h"
#include "appmenu/appmenumodel.h"
#include "appmenu/appmenuapplet.h"

#include "appearance.h"
#include "brightness.h"
#include "battery.h"
#include "volume.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    QString qmFilePath = QString("%1/%2.qm").arg("/usr/share/cutefish-statusbar/translations/").arg(QLocale::system().name());
    if (QFile::exists(qmFilePath)) {
        QTranslator *translator = new QTranslator(QApplication::instance());
        if (translator->load(qmFilePath)) {
            QGuiApplication::installTranslator(translator);
        } else {
            translator->deleteLater();
        }
    }

    const char *uri = "Cutefish.StatusBar";
    qmlRegisterType<SystemTrayModel>(uri, 1, 0, "SystemTrayModel");
    qmlRegisterType<ControlCenterDialog>(uri, 1, 0, "ControlCenterDialog");
    qmlRegisterType<Appearance>(uri, 1, 0, "Appearance");
    qmlRegisterType<Brightness>(uri, 1, 0, "Brightness");
    qmlRegisterType<Battery>(uri, 1, 0, "Battery");
    qmlRegisterType<VolumeManager>(uri, 1, 0, "Volume");
    qmlRegisterType<AppMenuModel>(uri, 1, 0, "AppMenuModel");
    qmlRegisterType<AppMenuApplet>(uri, 1, 0, "AppMenuApplet");

    StatusBar bar;

    return app.exec();
}
