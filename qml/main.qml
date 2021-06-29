/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     Reion Wong <aj@cutefishos.com>
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
 
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import Cutefish.StatusBar 1.0
import Cutefish.NetworkManagement 1.0 as NM
import FishUI 1.0 as FishUI

Item {
    id: rootItem

    property int iconSize: 16

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property bool darkMode: FishUI.Theme.darkMode
    property color textColor: rootItem.darkMode ? "#FFFFFF" : "#000000";

    // Hide if launchpad is encountered
    opacity: acticity.launchPad && windowHelper.compositing ? 0 : 1

    Rectangle {
        id: background
        anchors.fill: parent
        color: FishUI.Theme.darkMode ? "#333333" : "#FFFFFF"
        opacity: windowHelper.compositing ? FishUI.Theme.darkMode ? 0.5 : 0.7 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    FishUI.WindowHelper {
        id: windowHelper
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

    // Main layout
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing
        anchors.rightMargin: FishUI.Units.smallSpacing
        spacing: FishUI.Units.smallSpacing / 2

        // App name
        StandardItem {
            id: acticityItem
            Layout.fillHeight: true
            Layout.preferredWidth: acticityLayout.implicitWidth ? Math.min(acticityLayout.implicitWidth + FishUI.Units.largeSpacing,
                                                                           rootItem.width / 2)
                                                                : 0
            onRightClicked: acticityMenu.open()

            RowLayout {
                id: acticityLayout
                anchors.fill: parent
                anchors.leftMargin: FishUI.Units.smallSpacing
                anchors.rightMargin: FishUI.Units.smallSpacing
                spacing: FishUI.Units.smallSpacing

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
                    color: rootItem.textColor
                    visible: text
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: rootItem.height ? rootItem.height / 3 : 1
                }
            }
        }

        // App menu
        Item {
            id: appMenuItem
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: appMenuView
                anchors.fill: parent
                orientation: Qt.Horizontal
                spacing: FishUI.Units.smallSpacing
                visible: appMenuModel.visible
                interactive: false
                clip: true

                model: appMenuModel

                // Initialize the current index
                onVisibleChanged: {
                    if (!visible)
                        appMenuView.currentIndex = -1
                }

                delegate: StandardItem {
                    id: _menuItem
                    width: _actionText.width + FishUI.Units.largeSpacing
                    height: ListView.view.height
                    checked: appMenuApplet.currentIndex === index

                    onClicked: {
                        appMenuApplet.trigger(_menuItem, index)

                        checked = Qt.binding(function() {
                            return appMenuApplet.currentIndex === index
                        })
                    }

                    Text {
                        id: _actionText
                        anchors.centerIn: parent
                        color: rootItem.textColor
                        text: {
                            var text = activeMenu
                            text = text.replace(/([^&]*)&(.)([^&]*)/g, function (match, p1, p2, p3) {
                                return p1.concat(p2, p3)
                            })
                            return text
                        }
                    }

                    // QMenu opens on press, so we'll replicate that here
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: appMenuApplet.currentIndex !== -1
                        onPressed: parent.clicked()
                        onEntered: parent.clicked()
                    }
                }

                AppMenuModel {
                    id: appMenuModel
                    onRequestActivateIndex: appMenuApplet.requestActivateIndex(appMenuView.currentIndex)
                    Component.onCompleted: {
                        appMenuView.model = appMenuModel
                    }
                }

                AppMenuApplet {
                    id: appMenuApplet
                    model: appMenuModel
                }

                Component.onCompleted: {
                    appMenuApplet.buttonGrid = appMenuView

                    // Handle left and right shortcut keys.
                    appMenuApplet.requestActivateIndex.connect(function (index) {
                        var idx = Math.max(0, Math.min(appMenuView.count - 1, index))
                        var button = appMenuView.itemAtIndex(index)
                        if (button) {
                            button.clicked()
                        }
                    });

                    // Handle mouse movement.
                    appMenuApplet.mousePosChanged.connect(function (x, y) {
                        var item = itemAt(x, y)
                        if (item)
                            item.clicked();
                    });
                }
            }
        }

        // System tray(Right)
        ListView {
            id: trayView

            orientation: Qt.Horizontal
            layoutDirection: Qt.RightToLeft
            interactive: false
            clip: true
            spacing: FishUI.Units.smallSpacing / 2

            property real itemWidth: rootItem.iconSize + FishUI.Units.largeSpacing

            Layout.fillHeight: true
            Layout.preferredWidth: (itemWidth + (count - 1) * FishUI.Units.smallSpacing) * count

            model: SystemTrayModel {
                id: trayModel
            }

            delegate: StandardItem {
                width: trayView.itemWidth
                height: ListView.view.height

                property bool darkMode: rootItem.darkMode
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

            onClicked: toggleDialog()
            onRightClicked: toggleDialog()

            function toggleDialog() {
                if (controlCenter.visible)
                    controlCenter.visible = false
                else {
                    // 先初始化，用户可能会通过Alt鼠标左键移动位置
                    controlCenter.position = Qt.point(0, 0)
                    controlCenter.visible = true
                    controlCenter.position = Qt.point(mapToGlobal(0, 0).x, mapToGlobal(0, 0).y)
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
                    source: "qrc:/images/" + (rootItem.darkMode ? "dark/" : "light/") + volume.iconName + ".svg"
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
                    source: activeConnection.wirelessIcon ? "qrc:/images/" + (rootItem.darkMode ? "dark/" : "light/") + activeConnection.wirelessIcon + ".svg" : ""
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                    visible: enabledConnections.wirelessHwEnabled &&
                             enabledConnections.wirelessEnabled &&
                             activeConnection.wirelessName &&
                             wirelessIcon.status === Image.Ready
                }

                // Battery Item
                RowLayout {
                    visible: battery.available

                    Image {
                        id: batteryIcon
                        height: rootItem.iconSize
                        width: height + 6
                        sourceSize: Qt.size(width, height)
                        source: "qrc:/images/" + (rootItem.darkMode ? "dark/" : "light/") + battery.iconSource
                        Layout.alignment: Qt.AlignCenter
                    }

                    Label {
                        text: battery.chargePercent + "%"
                        font.pointSize: rootItem.height ? rootItem.height / 3 : 1
                        color: rootItem.textColor
                        visible: battery.showPercentage
                    }
                }
            }
        }

        // Pop-up notification center and calendar
        StandardItem {
            id: datetimeItem

            Layout.fillHeight: true
            Layout.preferredWidth: _dateTimeLayout.implicitWidth + FishUI.Units.smallSpacing

            RowLayout {
                id: _dateTimeLayout
                anchors.fill: parent

                Label {
                    id: timeLabel
                    Layout.alignment: Qt.AlignCenter
                    font.pointSize: rootItem.height ? rootItem.height / 3 : 1
                    color: rootItem.textColor

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
    ControlCenter {
        id: controlCenter
    }

    Volume {
        id: volume
    }

    NM.ActiveConnection {
        id: activeConnection
    }

    NM.EnabledConnections {
        id: enabledConnections
    }

    NM.Handler {
        id: nmHandler
    }
}
