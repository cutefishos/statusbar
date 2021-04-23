import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import Cutefish.StatusBar 1.0
import Cutefish.NetworkManagement 1.0 as NM
import FishUI 1.0 as FishUI

Item {
    id: rootItem

    property int iconSize: 16 * Screen.devicePixelRatio

    Rectangle {
        id: background
        anchors.fill: parent
        color: FishUI.Theme.backgroundColor
        opacity: FishUI.Theme.darkMode ? 0.6 : 0.8

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    FishUI.PopupTips {
        id: popupTips
        backgroundColor: FishUI.Theme.backgroundColor
        backgroundOpacity: FishUI.Theme.darkMode ? 0.3 : 0.4
    }

    FishUI.DesktopMenu {
        id: acticityMenu

        MenuItem {
            text: qsTr("Close")
            onTriggered: acticity.close()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing
        anchors.rightMargin: FishUI.Units.smallSpacing
        spacing: FishUI.Units.smallSpacing

        StandardItem {
            id: acticityItem
            Layout.fillHeight: true
            Layout.preferredWidth: acticityLayout.implicitWidth ? Math.min(acticityLayout.implicitWidth + FishUI.Units.largeSpacing,
                                                                           rootItem.width / 2)
                                                                : 0
            onClicked: acticityMenu.open()

            RowLayout {
                id: acticityLayout
                anchors.fill: parent
                anchors.leftMargin: FishUI.Units.smallSpacing
                anchors.rightMargin: FishUI.Units.smallSpacing
                spacing: FishUI.Units.smallSpacing * 1.5

                Image {
                    id: acticityIcon
                    width: rootItem.iconSize
                    height: rootItem.iconSize
                    sourceSize: Qt.size(rootItem.iconSize,
                                        rootItem.iconSize)
                    source: acticity.icon ? "image://icontheme/" + acticity.icon : ""
                    visible: status === Image.Ready
                }

                Label {
                    id: acticityLabel
                    text: acticity.title
                    Layout.fillWidth: true
                    elide: Qt.ElideRight
                    color: FishUI.Theme.darkMode ? 'white' : 'black'
                    visible: text
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: rootItem.height ? rootItem.height / 3 : 1
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ListView {
            id: trayView

            orientation: Qt.Horizontal
            layoutDirection: Qt.RightToLeft
            interactive: false
            clip: true
            spacing: FishUI.Units.smallSpacing

            property var itemSize: rootItem.height * 0.8
            property var itemWidth: itemSize + FishUI.Units.smallSpacing

            Layout.fillHeight: true
            Layout.preferredWidth: (itemWidth + (count - 1) * FishUI.Units.smallSpacing) * count

            model: SystemTrayModel {
                id: trayModel
            }

            delegate: StandardItem {
                width: trayView.itemWidth
                height: ListView.view.height

                property bool darkMode: FishUI.Theme.darkMode
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
                }

                onClicked: trayModel.leftButtonClick(model.id)
                onRightClicked: trayModel.rightButtonClick(model.id)
                popupText: model.toolTip ? model.toolTip : model.title
            }
        }

        StandardItem {
            id: controler

            Layout.fillHeight: true
            Layout.preferredWidth: _controlerLayout.implicitWidth + FishUI.Units.largeSpacing

            onClicked: {
                if (controlDialog.visible)
                    controlDialog.visible = false
                else {
                    // 先初始化，用户可能会通过Alt鼠标左键移动位置
                    controlDialog.position = Qt.point(0, 0)
                    controlDialog.visible = true
                    controlDialog.position = Qt.point(mapToGlobal(0, 0).x, mapToGlobal(0, 0).y)
                }
            }

            RowLayout {
                id: _controlerLayout
                anchors.fill: parent
                anchors.leftMargin: FishUI.Units.smallSpacing
                anchors.rightMargin: FishUI.Units.smallSpacing

                spacing: FishUI.Units.largeSpacing

                Image {
                    id: volumeIcon
                    visible: volume.isValid && status === Image.Ready
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + volume.iconName + ".svg"
                    width: rootItem.iconSize
                    height: width
                    sourceSize: Qt.size(width, height)
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }

                Image {
                    id: wirelessIcon
                    width: rootItem.iconSize
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: network.wirelessIconName ? "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + network.wirelessIconName + ".svg" : ""
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                    visible: network.enabled &&
                             network.wirelessEnabled &&
                             network.wirelessConnectionName !== "" &&
                             wirelessIcon.status === Image.Ready
                }

                // Battery Item
                RowLayout {
                    visible: battery.available

                    Image {
                        id: batteryIcon
                        height: rootItem.iconSize
                        width: height + (6 * Screen.devicePixelRatio)
                        sourceSize: Qt.size(width, height)
                        source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                        Layout.alignment: Qt.AlignCenter
                    }

                    Label {
                        text: battery.chargePercent + "%"
                        font.pointSize: rootItem.height ? rootItem.height / 3 : 1
                        color: FishUI.Theme.darkMode ? 'white' : 'black'
                        visible: battery.showPercentage
                    }
                }

                Label {
                    id: timeLabel
                    Layout.alignment: Qt.AlignCenter
                    font.pointSize: rootItem.height ? rootItem.height / 3 : 1
                    color: FishUI.Theme.darkMode ? 'white' : 'black'

                    Timer {
                        interval: 1000
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: {
                            timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        }
                    }
                }
            }
        }
    }

    // Components
    ControlDialog {
        id: controlDialog
    }

    Volume {
        id: volume
    }

    Battery {
        id: battery
    }

    NM.ConnectionIcon {
        id: connectionIconProvider
    }

    NM.Network {
        id: network
    }
}
