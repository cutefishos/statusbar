#ifndef STATUSBAR_H
#define STATUSBAR_H

#include <QQuickView>

class StatusBar : public QQuickView
{
    Q_OBJECT

public:
    explicit StatusBar(QQuickView *parent = nullptr);

    void updateGeometry();
    void updateViewStruts();
};

#endif // STATUSBAR_H
