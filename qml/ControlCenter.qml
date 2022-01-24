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
import Cutefish.Bluez 1.0 as Bluez
import Cutefish.StatusBar 1.0
import Cutefish.Audio 1.0
import FishUI 1.0 as FishUI

ControlCenterDialog {
    id: control

    width: 420
    height: _mainLayout.implicitHeight + FishUI.Units.largeSpacing * 2.5

    property var margin: 4 * Screen.devicePixelRatio
    property point position: Qt.point(0, 0)
    property var defaultSink: paSinkModel.defaultSink

    property bool bluetoothDisConnected: Bluez.Manager.bluetoothBlocked
    property var defaultSinkValue: defaultSink ? defaultSink.volume / PulseAudio.NormalVolume * 100.0 : -1

    property var borderColor: windowHelper.compositing ? FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                                  : Qt.rgba(0, 0, 0, 0.2) : FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.15)
                                                                                                                  : Qt.rgba(0, 0, 0, 0.15)

    property var volumeIconName: {
        if (defaultSinkValue <= 0)
            return "audio-volume-muted-symbolic"
        else if (defaultSinkValue <= 25)
            return "audio-volume-low-symbolic"
        else if (defaultSinkValue <= 75)
            return "audio-volume-medium-symbolic"
        else
            return "audio-volume-high-symbolic"
    }

    onBluetoothDisConnectedChanged: {
        bluetoothItem.checked = !bluetoothDisConnected
    }

    onWidthChanged: adjustCorrectLocation()
    onHeightChanged: adjustCorrectLocation()
    onPositionChanged: adjustCorrectLocation()

    color: "transparent"

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Appearance {
        id: appearance
    }

    SinkModel {
        id: paSinkModel

        onDefaultSinkChanged: {
            if (!defaultSink) {
                return
            }
        }
    }

    function toggleBluetooth() {
        const enable = !control.bluetoothDisConnected
        Bluez.Manager.bluetoothBlocked = enable

        for (var i = 0; i < Bluez.Manager.adapters.length; ++i) {
            var adapter = Bluez.Manager.adapters[i]
            adapter.powered = enable
        }
    }

    function adjustCorrectLocation() {
        var posX = control.position.x
        var posY = control.position.y

        if (posX + control.width >= StatusBar.screenRect.x + StatusBar.screenRect.width)
            posX = StatusBar.screenRect.x + StatusBar.screenRect.width - control.width - control.margin

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
        radius: windowHelper.compositing ? FishUI.Theme.bigRadius * 1.5 : 0
        color: FishUI.Theme.darkMode ? "#4D4D4D" : "#FFFFFF"
        opacity: windowHelper.compositing ? FishUI.Theme.darkMode ? 0.5 : 0.7 : 1.0
        antialiasing: true
        border.width: 1 / Screen.devicePixelRatio
        border.pixelAligned: Screen.devicePixelRatio > 1 ? false : true
        border.color: control.borderColor

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.largeSpacing * 1.5
        anchors.rightMargin: FishUI.Units.largeSpacing * 1.5
        anchors.topMargin: FishUI.Units.largeSpacing * 1.5
        anchors.bottomMargin: FishUI.Units.largeSpacing
        spacing: FishUI.Units.largeSpacing

        Item {
            id: topItem
            Layout.fillWidth: true
            height: 36

            RowLayout {
                id: topItemLayout
                anchors.fill: parent
                spacing: FishUI.Units.largeSpacing

                Image {
                    id: userIcon

                    property int iconSize: 36

                    Layout.preferredHeight: iconSize
                    Layout.preferredWidth: iconSize
                    sourceSize: String(source) === "image://icontheme/default-user" ? Qt.size(iconSize, iconSize) : undefined
                    source: currentUser.iconFileName ? "file:///" + currentUser.iconFileName : "image://icontheme/default-user"
                    antialiasing: true
                    smooth: false

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
                    implicitWidth: topItem.height
                    implicitHeight: topItem.height
                    Layout.alignment: Qt.AlignTop
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "settings.svg"
                    onLeftButtonClicked: {
                        control.visible = false
                        process.startDetached("cutefish-settings")
                    }
                }

//                IconButton {
//                    id: shutdownButton
//                    implicitWidth: topItem.height
//                    implicitHeight: topItem.height
//                    Layout.alignment: Qt.AlignTop
//                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "system-shutdown-symbolic.svg"
//                    onLeftButtonClicked: {
//                        control.visible = false
//                        process.startDetached("cutefish-shutdown")
//                    }
//                }
            }
        }

        Item {
            id: cardItems
            Layout.fillWidth: true
            height: 100
            visible: wirelessItem.visible || bluetoothItem.visible

            RowLayout {
                anchors.fill: parent
                spacing: FishUI.Units.largeSpacing

                CardItem {
                    id: wirelessItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: 120
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/network-wireless-connected-100.svg"
                                                           : "qrc:/images/light/network-wireless-connected-100.svg"
                    visible: enabledConnections.wirelessHwEnabled
                    checked: enabledConnections.wirelessEnabled
                    label: qsTr("Wi-Fi")
                    text: enabledConnections.wirelessEnabled ? activeConnection.wirelessName ?
                                                               activeConnection.wirelessName :
                                                               qsTr("On") : qsTr("Off")
                    onClicked: nmHandler.enableWireless(!checked)
                    onPressAndHold: {
                        control.visible = false
                        process.startDetached("cutefish-settings", ["-m", "wlan"])
                    }
                }

                CardItem {
                    id: bluetoothItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: 120
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/bluetooth-symbolic.svg"
                                                         : "qrc:/images/light/bluetooth-symbolic.svg"
                    checked: !control.bluetoothDisConnected
                    label: qsTr("Bluetooth")
                    text: checked ? qsTr("On") : qsTr("Off")
                    visible: Bluez.Manager.adapters.length
                    onClicked: control.toggleBluetooth()
                    onPressAndHold: {
                        control.visible = false
                        process.startDetached("cutefish-settings", ["-m", "bluetooth"])
                    }
                }

                CardItem {
                    id: darkModeItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: 120
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/dark-mode.svg"
                                                         : "qrc:/images/light/dark-mode.svg"
                    checked: FishUI.Theme.darkMode
                    label: qsTr("Dark Mode")
                    text: FishUI.Theme.darkMode ? qsTr("On") : qsTr("Off")
                    onClicked: appearance.switchDarkMode(!FishUI.Theme.darkMode)
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        MprisItem {
            height: 96
            Layout.fillWidth: true
        }

        Item {
            id: brightnessItem
            Layout.fillWidth: true
            height: 40
            visible: brightness.enabled

            Rectangle {
                id: brightnessItemBg
                anchors.fill: parent
                radius: FishUI.Theme.bigRadius
                color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1)
                                             : Qt.rgba(0, 0, 0, 0.05)
            }

            RowLayout {
                anchors.fill: brightnessItemBg
                anchors.leftMargin: FishUI.Units.largeSpacing
                anchors.rightMargin: FishUI.Units.largeSpacing
                anchors.topMargin: FishUI.Units.smallSpacing
                anchors.bottomMargin: FishUI.Units.smallSpacing
                spacing: FishUI.Units.largeSpacing

                Image {
                    height: 16
                    width: height
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/brightness.svg"
                    smooth: false
                    antialiasing: true
                }

                Timer {
                    id: brightnessTimer
                    interval: 100
                    repeat: false
                    onTriggered: brightness.setValue(brightnessSlider.value)
                }

                Slider {
                    id: brightnessSlider
                    from: 1
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
            height: 40
            visible: defaultSink

            Rectangle {
                id: volumeItemBg
                anchors.fill: parent
                radius: FishUI.Theme.bigRadius
                color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1)
                                             : Qt.rgba(0, 0, 0, 0.05)
            }

            RowLayout {
                anchors.fill: volumeItemBg
                anchors.leftMargin: FishUI.Units.largeSpacing
                anchors.rightMargin: FishUI.Units.largeSpacing
                anchors.topMargin: FishUI.Units.smallSpacing
                anchors.bottomMargin: FishUI.Units.smallSpacing
                spacing: FishUI.Units.largeSpacing

                Image {
                    height: 16
                    width: height
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/" + control.volumeIconName + ".svg"
                    smooth: false
                    antialiasing: true
                }

                Slider {
                    id: volumeSlider

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    from: PulseAudio.MinimalVolume
                    to: PulseAudio.MaximalVolume

                    stepSize: to / (to / PulseAudio.MaximalVolume * 100.0)

                    value: defaultSink ? defaultSink.volume : 0

                    onValueChanged: {
                        if (!defaultSink)
                            return

                        defaultSink.volume = value
                        defaultSink.muted = (value === 0)
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
                        timeLabel.text = new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat)
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
                        antialiasing: true
                        smooth: false
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
