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
    property var fontSize: rootItem.height ? rootItem.height / 3 : 1

    property var timeFormat: StatusBar.twentyFourTime ? "HH:mm" : "h:mm ap"

    onTimeFormatChanged: {
        timeTimer.restart()
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: FishUI.Theme.darkMode ? "#4D4D4D" : "#FFFFFF"
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
        backgroundColor: background.color
        backgroundOpacity: background.opacity
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
            animationEnabled: true
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
                    antialiasing: true
                    smooth: false
                }

                Label {
                    id: acticityLabel
                    text: acticity.title
                    Layout.fillWidth: true
                    elide: Qt.ElideRight
                    color: rootItem.textColor
                    visible: text
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: rootItem.fontSize
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
                        font.pointSize: rootItem.fontSize
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

            moveDisplaced: Transition {
                NumberAnimation {
                    properties: "x, y"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            delegate: StandardItem {
                id: _trayItem

                property bool darkMode: rootItem.darkMode
                property int dragItemIndex: index
                property bool dragStarted: false

                width: trayView.itemWidth
                height: ListView.view.height
                animationEnabled: true

                onDarkModeChanged: updateTimer.restart()

                Drag.active: _trayItem.mouseArea.drag.active
                Drag.dragType: Drag.Automatic
                Drag.supportedActions: Qt.MoveAction
                Drag.hotSpot.x: iconItem.width / 2
                Drag.hotSpot.y: iconItem.height / 2

                Drag.onDragStarted:  {
                    dragStarted = true
                }

                Drag.onDragFinished: {
                    dragStarted = false
                }

                onPositionChanged: {
                    if (_trayItem.mouseArea.pressed) {
                        _trayItem.mouseArea.drag.target = iconItem
                        iconItem.grabToImage(function(result) {
                            _trayItem.Drag.imageSource = result.url
                        })
                    } else {
                        _trayItem.mouseArea.drag.target = null
                    }
                }

                onReleased: {
                    _trayItem.mouseArea.drag.target = null
                }

                DropArea {
                    anchors.fill: parent
                    enabled: true

                    onEntered: {
                        if (drag.source)
                            trayModel.move(drag.source.dragItemIndex,
                                           _trayItem.dragItemIndex)
                    }
                }

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
                    visible: !dragStarted
                }

                onClicked: trayModel.leftButtonClick(model.id)
                onRightClicked: trayModel.rightButtonClick(model.id)
                popupText: model.toolTip ? model.toolTip : model.title
            }
        }

        StandardItem {
            id: controler

            checked: controlCenter.visible
            animationEnabled: true
            Layout.fillHeight: true
            Layout.preferredWidth: _controlerLayout.implicitWidth + FishUI.Units.largeSpacing

            onClicked: toggleDialog()
            onRightClicked: toggleDialog()

            function toggleDialog() {
                if (controlCenter.visible)
                    controlCenter.close()
                else {
                    // 先初始化，用户可能会通过Alt鼠标左键移动位置
                    controlCenter.position = Qt.point(0, 0)
                    controlCenter.position = mapToGlobal(0, 0)
                    controlCenter.open()
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
                    visible: controlCenter.defaultSink
                    source: "qrc:/images/" + (rootItem.darkMode ? "dark/" : "light/") + controlCenter.volumeIconName + ".svg"
                    width: rootItem.iconSize
                    height: width
                    sourceSize: Qt.size(width, height)
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                    antialiasing: true
                    smooth: false
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
                    antialiasing: true
                    smooth: false
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
                        antialiasing: true
                        smooth: false
                    }

                    Label {
                        text: battery.chargePercent + "%"
                        font.pointSize: rootItem.fontSize
                        color: rootItem.textColor
                        visible: battery.showPercentage
                    }
                }

                Image {
                    id: shutdownIcon
                    width: rootItem.iconSize
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/images/" + (rootItem.darkMode ? "dark/" : "light/") + "system-shutdown-symbolic.svg"
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                    visible: !batteryIcon.visible
                    antialiasing: true
                    smooth: false
                }
            }
        }

        // Pop-up notification center and calendar
        StandardItem {
            id: datetimeItem

            animationEnabled: true
            Layout.fillHeight: true
            Layout.preferredWidth: _dateTimeLayout.implicitWidth + FishUI.Units.smallSpacing

            onClicked: {
                process.startDetached("cutefish-notificationd", ["-s"])
            }

            RowLayout {
                id: _dateTimeLayout
                anchors.fill: parent

//                Image {
//                    width: rootItem.iconSize
//                    height: width
//                    sourceSize: Qt.size(width, height)
//                    source: "qrc:/images/" + (rootItem.darkMode ? "dark/" : "light/") + "notification-symbolic.svg"
//                    asynchronous: true
//                    Layout.alignment: Qt.AlignCenter
//                    antialiasing: true
//                    smooth: false
//                }

                Label {
                    id: timeLabel
                    Layout.alignment: Qt.AlignCenter
                    font.pointSize: rootItem.fontSize
                    color: rootItem.textColor

                    Timer {
                        id: timeTimer
                        interval: 1000
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: {
                            timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), rootItem.timeFormat)
                        }
                    }
                }
            }
        }

    }

    MouseArea {
        id: _sliding
        anchors.fill: parent
        z: -1

        property int startY: -1
        property bool activated: false

        onActivatedChanged: {
            // TODO
            // if (activated)
            //     acticity.move()
        }

        onPressed: {
            startY = mouse.y
        }

        onReleased: {
            startY = -1
        }

        onDoubleClicked: {
            acticity.toggleMaximize()
        }

        onMouseYChanged: {
            if (startY === parseInt(mouse.y)) {
                activated = false
                return
            }

            // Up
            if (startY > parseInt(mouse.y)) {
                activated = false
                return
            }

            if (mouse.y > rootItem.height)
                activated = true
            else
                activated = false
        }
    }

    // Components
    ControlCenter {
        id: controlCenter
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
