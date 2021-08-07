import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import Cutefish.StatusBar 1.0
import FishUI 1.0 as FishUI

ListView {
    id: trayView

    orientation: Qt.Horizontal
    layoutDirection: Qt.RightToLeft
    interactive: false
    spacing: FishUI.Units.smallSpacing / 2
    clip: true

    property real itemWidth: rootItem.iconSize + FishUI.Units.largeSpacing

    Layout.fillHeight: true
    Layout.preferredWidth: (itemWidth + (count - 1) * FishUI.Units.smallSpacing) * count

    model: SystemTrayModel {
        id: trayModel
    }

    delegate: StandardItem {
        property bool darkMode: rootItem.darkMode

        width: trayView.itemWidth
        height: ListView.view.height
        animationEnabled: true

        onDarkModeChanged: updateTimer.restart()

        Timer {
            id: updateTimer
            interval: 10
            onTriggered: iconItem.updateIcon()
        }

        FishUI.IconItem {
            id: iconItem
            anchors.centerIn: parent
            width: rootItem.iconSize
            height: width
            source: model.iconName ? model.iconName : model.icon
            antialiasing: true
            smooth: false
        }

        onClicked: trayModel.leftButtonClick(model.id)
        onRightClicked: trayModel.rightButtonClick(model.id)
        popupText: model.toolTip ? model.toolTip : model.title
    }
}
