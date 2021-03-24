#include <QApplication>
#include <QTranslator>
#include <QLocale>

#include "statusbar.h"
#include "controlcenterdialog.h"
#include "systemtray/systemtraymodel.h"

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

    StatusBar bar;

    return app.exec();
}
