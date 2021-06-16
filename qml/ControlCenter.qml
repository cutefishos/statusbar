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
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import Cutefish.Accounts 1.0 as Accounts
import Cutefish.StatusBar 1.0
import FishUI 1.0 as FishUI

ControlCenterDialog {
    id: control

    width: 450
    height: _mainLayout.implicitHeight + FishUI.Units.largeSpacing * 3

    property var margin: 4 * Screen.devicePixelRatio
    property point position: Qt.point(0, 0)

    onWidthChanged: adjustCorrectLocation()
    onHeightChanged: adjustCorrectLocation()
    onPositionChanged: adjustCorrectLocation()

    color: "transparent"

    Appearance {
        id: appearance
    }

    function adjustCorrectLocation() {
        var posX = control.position.x
        var posY = control.position.y

        if (posX + control.width >= Screen.width)
            posX = Screen.width - control.width - control.margin

        posY = rootItem.y + rootItem.height + control.margin

        control.x = posX
        control.y = posY
    }

    Brightness {
        id: brightness
    }

    Accounts.UserAccount {
        id: currentUser
    }

    FishUI.WindowBlur {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        windowRadius: _background.radius
        enabled: true
    }

    FishUI.WindowShadow {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        radius: _background.radius
    }

    Rectangle {
        id: _background
        anchors.fill: parent
        radius: control.height * 0.05
        color: FishUI.Theme.darkMode ? "#333333" : "#FFFFFF"
        opacity: FishUI.Theme.darkMode ? 0.5 : 0.7
        antialiasing: true
        border.width: 0
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.largeSpacing * 1.5
        anchors.topMargin: FishUI.Units.largeSpacing * 1.5
        anchors.rightMargin: FishUI.Units.largeSpacing * 1.5
        anchors.bottomMargin: FishUI.Units.largeSpacing
        spacing: FishUI.Units.largeSpacing

        Item {
            id: topItem
            Layout.fillWidth: true
            height: 48

            RowLayout {
                id: topItemLayout
                anchors.fill: parent
                spacing: FishUI.Units.largeSpacing

                Image {
                    id: userIcon
                    height: 40
                    width: height
                    sourceSize: Qt.size(width, width)
                    source: currentUser.iconFileName ? "file:///" + currentUser.iconFileName : "image://icontheme/default-user"

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Item {
                            width: userIcon.width
                            height: userIcon.height

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.height / 2
                            }
                        }
                    }
                }

                Label {
                    id: userLabel
                    text: currentUser.userName
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    elide: Label.ElideRight
                }

                IconButton {
                    id: settingsButton
                    implicitWidth: topItem.height * 0.8
                    implicitHeight: topItem.height * 0.8
                    Layout.alignment: Qt.AlignTop
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "settings.svg"
                    onLeftButtonClicked: {
                        control.visible = false
                        process.startDetached("cutefish-settings")
                    }
                }

                IconButton {
                    id: shutdownButton
                    implicitWidth: topItem.height * 0.8
                    implicitHeight: topItem.height * 0.8
                    Layout.alignment: Qt.AlignTop
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "system-shutdown-symbolic.svg"
                    onLeftButtonClicked: {
                        control.visible = false
                        process.startDetached("cutefish-shutdown")
                    }
                }
            }
        }

        Item {
            id: cardItems
            Layout.fillWidth: true
            height: 110
            visible: wirelessItem.visible || bluetoothItem.visible

            RowLayout {
                anchors.fill: parent
                spacing: FishUI.Units.largeSpacing

                CardItem {
                    id: wirelessItem
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/network-wireless-connected-100.svg"
                                                           : "qrc:/images/light/network-wireless-connected-100.svg"
                    visible: enabledConnections.wirelessHwEnabled
                    checked: enabledConnections.wirelessEnabled
                    label: qsTr("Wi-Fi")
                    text: enabledConnections.wirelessEnabled ? activeConnection.wirelessName ?
                                                               activeConnection.wirelessName :
                                                               qsTr("On") : qsTr("Off")
                    onClicked: nmHandler.enableWireless(!checked)
                }

                CardItem {
                    id: bluetoothItem
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/bluetooth-symbolic.svg"
                                                         : "qrc:/images/light/bluetooth-symbolic.svg"
                    checked: false
                    label: qsTr("Bluetooth")
                    text: qsTr("Off")
                }

                CardItem {
                    id: darkModeItem
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/dark-mode.svg"
                                                         : "qrc:/images/light/dark-mode.svg"
                    checked: FishUI.Theme.darkMode
                    label: qsTr("Dark Mode")
                    text: FishUI.Theme.darkMode ? qsTr("On") : qsTr("Off")
                    onClicked: appearance.switchDarkMode(!FishUI.Theme.darkMode)
                }
            }
        }

        Item {
            id: brightnessItem
            Layout.fillWidth: true
            height: 45
            visible: brightness.enabled

            Rectangle {
                id: brightnessItemBg
                anchors.fill: parent
                radius: FishUI.Theme.bigRadius
                color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.4)
                                             : Qt.rgba(0, 0, 0, 0.1)
                opacity: FishUI.Theme.darkMode ? 0.3 : 0.5
            }

            RowLayout {
                anchors.fill: brightnessItemBg
                anchors.margins: FishUI.Units.largeSpacing
                spacing: FishUI.Units.largeSpacing

                Image {
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/brightness.svg"
                }

                Timer {
                    id: brightnessTimer
                    interval: 100
                    repeat: false
                    onTriggered: brightness.setValue(brightnessSlider.value)
                }

                Slider {
                    id: brightnessSlider
                    from: 0
                    to: 100
                    stepSize: 1
                    value: brightness.value
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onMoved: brightnessTimer.start()
                }
            }
        }

        Item {
            id: volumeItem
            Layout.fillWidth: true
            height: 45
            visible: volume.isValid

            Rectangle {
                id: volumeItemBg
                anchors.fill: parent
                radius: FishUI.Theme.bigRadius
                color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.4)
                                             : Qt.rgba(0, 0, 0, 0.1)
                opacity: FishUI.Theme.darkMode ? 0.3 : 0.5
            }

            RowLayout {
                anchors.fill: volumeItemBg
                anchors.margins: FishUI.Units.largeSpacing
                spacing: FishUI.Units.largeSpacing

                Image {
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/" + volume.iconName + ".svg"
                }

                Slider {
                    id: slider
                    from: 0
                    to: 100
                    stepSize: 1
                    value: volume.volume
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onValueChanged: {
                        volume.setVolume(value)

                        if (volume.isMute && value > 0)
                            volume.setMute(false)
                    }
                }
            }
        }

        RowLayout {
            spacing: 0

            Label {
                id: timeLabel
                leftPadding: FishUI.Units.smallSpacing / 2
                color: FishUI.Theme.textColor

                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: {
                        timeLabel.text = new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StandardItem {
                width: batteryLayout.implicitWidth + FishUI.Units.largeSpacing
                height: batteryLayout.implicitHeight + FishUI.Units.largeSpacing

                onClicked: {
                    control.visible = false
                    process.startDetached("cutefish-settings", ["-m", "battery"])
                }

                RowLayout {
                    id: batteryLayout
                    anchors.fill: parent
                    visible: battery.available
                    spacing: 0

                    Image {
                        id: batteryIcon
                        width: 22
                        height: 16
                        sourceSize: Qt.size(width, height)
                        source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                        asynchronous: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    Label {
                        text: battery.chargePercent + "%"
                        color: FishUI.Theme.textColor
                        rightPadding: FishUI.Units.smallSpacing / 2
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
