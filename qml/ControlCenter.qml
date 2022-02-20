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
import Cutefish.NetworkManagement 1.0 as NM


ControlCenterDialog {
    id: control
      width:400
    //width: 320
    height: _mainLayout.implicitHeight + FishUI.Units.largeSpacing * 2
    property bool checked: false
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
        color: FishUI.Theme.darkMode ? "#4D4D4D" : "#F0F0F0"
        opacity: windowHelper.compositing ? FishUI.Theme.darkMode ? 0.6 : 0.8 : 1.0
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
        anchors.margins: FishUI.Units.largeSpacing
        spacing: FishUI.Units.largeSpacing
        Item {
                   id: topItem
                   Layout.fillWidth: true
                   height: 32

                   RowLayout {
                       id: topItemLayout
                       anchors.fill: parent
                       anchors.rightMargin: FishUI.Units.largeSpacing
                       spacing: FishUI.Units.largeSpacing

                       Label {
                           leftPadding: FishUI.Units.largeSpacing
                           text: qsTr("Control Center")
                           font.bold: true
                           font.pointSize: 14
                           Layout.fillWidth: true
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


        RowLayout {
            id: middleItemLayout
            anchors.rightMargin: FishUI.Units.largeSpacing
            spacing: FishUI.Units.largeSpacing

        Item {
            id: cardItems
            Layout.fillWidth: true
            height: 150

            property var cellWidth: cardItems.width / 3

            Rectangle {
                anchors.fill: parent
                color: FishUI.Theme.darkMode ? "#AEAEAE" : "white"
                radius: FishUI.Theme.bigRadius
                opacity: 0.8
            }
            GridLayout {
                anchors.fill: parent
                anchors.topMargin: 9
                columnSpacing:1
                columns: 1
                CardItem {
                     Item {Layout.fillHeight: true}
                    label2: "          "+"Wi-Fi"
                    Item{Layout.fillHeight: true}
                    id: wirelessItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: cardItems.cellWidth
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/network-wireless-connected-100.svg"
                                                           : "qrc:/images/light/network-wireless-connected-100.svg"
                    visible: enabledConnections.wirelessHwEnabled
                    checked: enabledConnections.wirelessEnabled
                    label:activeConnection.wirelessName ? activeConnection.wirelessName : qsTr("Wi-Fi")
                    onClicked: nmHandler.enableWireless(!checked)
                    onPressAndHold: {
                        control.visible = false
                        process.startDetached("cutefish-settings", ["-m", "wlan"])
                    }
                }
                CardItem {
                    label2: "          "+"Bluetooth"
                    Item{Layout.fillHeight: true}
                    id: bluetoothItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: cardItems.cellWidth
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/bluetooth-symbolic.svg"
                                                           : "qrc:/images/light/bluetooth-symbolic.svg"
                    checked: !control.bluetoothDisConnected
                    label:!control.bluetoothDisConnected ?qsTr("On")
                                                   :qsTr("Off")
                    visible: Bluez.Manager.adapters.length
                    onClicked: control.toggleBluetooth()
                    onPressAndHold: {
                        control.visible = false
                        process.startDetached("cutefish-settings", ["-m", "bluetooth"])
                    }
                }

                CardItem {
                    label2: "          "+"Hotspot"
                    Item{Layout.fillHeight: true}
                    id: hotspot
                    Layout.fillHeight: true
                    Layout.preferredWidth: cardItems.cellWidth
                    icon//: FishUI.Theme.darkMode || checked ? "qrc:/images/light/hotspot.svg"
                                                           : "qrc:/images/dark/hotspot.svg"
                    checked:handler.hotspotSupported
                    label:qsTr("Not Supported")
                    onClicked: if (checked) {
                                   handler.createHotspot()
                               } else {
                                   handler.stopHotspot()
                               }
                }
            }
        }
        ColumnLayout {
            id: middleItemLayout2
           anchors.margins: FishUI.Units.largeSpacing
            spacing: FishUI.Units.largeSpacing

            Item {
                id: doNotDisturb
                Layout.fillWidth: true
                height: 69
                 property var cellWidth: cardItems.width / 3
                Rectangle {
                    anchors.fill: parent
                    color: FishUI.Theme.darkMode ? "#AEAEAE" : "white"
                    radius: FishUI.Theme.bigRadius
                    opacity: 0.8

                }
                GridLayout{anchors.fill: parent
                    anchors.topMargin: 9
                    columnSpacing:1
                    columns: 2
                    Layout.alignment: Qt.AlignCenter
                    GridLayout {
                        anchors.fill: parent
                        anchors.topMargin: 7
                        anchors.leftMargin: 10
                        anchors.rightMargin: 5
                        anchors.bottomMargin: 25

                        columnSpacing:1
                        columns: 1
                    CardItem {
                                       Layout.fillHeight: true
                                       Layout.preferredWidth: cardItems.cellWidth
                                       icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/dnd.svg"
                                                                              : "qrc:/images/light/dnd.svg"
                                       checked: false
                                       label: qsTr("")
                                       visible: Bluez.Manager.adapters.length

                                      onPressAndHold: {
                                           control.visible = false
                                           process.startDetached("cutefish-settings", ["-m", "notifications",])
                                       }
                    }}

                    Label {
                        anchors.fill: parent
                        topPadding: 6
                          leftPadding:63
                        rightPadding:10
                        bottomPadding: 35
                        Layout.alignment: Qt.AlignCenter+Qt.AlignVCenter
                        text: qsTr("Do Not\n")+qsTr("Disturb")
                        font.bold: true
                        font.pointSize: 12
                       Layout.fillWidth: true
                        wrapMode: "WordWrap"
                    }
                }
            }
            GridLayout {
                anchors.fill: parent
                anchors.topMargin: 80
              //  Layout.alignment: Qt.AlignCenter

                columnSpacing:1
                columns: 2
        Item {
            id: darkMode
            Layout.fillWidth: true
            height: 69           
            property var cellWidth: cardItems.width / 3
            Rectangle {
                anchors.fill: parent
                color: FishUI.Theme.darkMode ? "#AEAEAE" : "white"
                radius: FishUI.Theme.bigRadius
                opacity: 0.8}
            GridLayout {
                anchors.fill: parent
                anchors.topMargin: 7
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                anchors.bottomMargin: 25

                columnSpacing:1
                columns: 1
                IconButton {

                    implicitWidth:40
                    implicitHeight:40
                    Layout.alignment: Qt.AlignVCenter+Qt.AlignHCenter
                    checked: FishUI.Theme.darkMode
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "light/" : "dark/") + "dark-mode.svg"
                    onLeftButtonClicked: appearance.switchDarkMode(!FishUI.Theme.darkMode)
                    onPressAndHold:{control.visible = false
                        process.startDetached("cutefish-settings",["-m","appearance"])

                    }
                }

            }

            Label {
                    topPadding: 50
                    leftPadding: FishUI.Units.largeSpacing*2
                    rightPadding: FishUI.Units.largeSpacing*2
                    text: qsTr("Dark Mode")
                    font.bold: true
                    font.pointSize: 7
                    Layout.fillWidth: true
                }
     /*   Label{
            topPadding: 57
            leftPadding:12
            rightPadding:15
            font.pointSize: 6
            font.bold: false
        text:FishUI.Theme.darkMode || checked ? qsTr("Dark-layout")
                                              :qsTr("Light-layout")

        }*/}
        Item {
            id: screenshot
            Layout.fillWidth: true
            height: 69
             property var cellWidth: cardItems.width / 3
            Rectangle {
                anchors.fill: parent
                color: FishUI.Theme.darkMode ? "#AEAEAE" : "white"
                radius: FishUI.Theme.bigRadius
                anchors.leftMargin: 5
                opacity: 0.8

            }anchors.leftMargin: 25
            anchors.topMargin: 25
            GridLayout {
                anchors.fill: parent
                anchors.topMargin: 7
                anchors.leftMargin: 7
                anchors.rightMargin: 5
                anchors.bottomMargin: 25

                columnSpacing:1
                columns: 1
            IconButton {
                id: screenshotButton
                implicitWidth:40
                implicitHeight:40
                Layout.alignment: Qt.AlignVCenter+Qt.AlignHCenter
                source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "screenshot.svg"
                checked: false
                onLeftButtonClicked: {
                    control.visible = true
                    process.startDetached("cutefish-screenshot",["-d","500"])
                }
            }}
            Label {
                topPadding: 50
                leftPadding: FishUI.Units.largeSpacing*2
                rightPadding: FishUI.Units.largeSpacing*2
                text: qsTr("Screenshot")                
                font.bold: true
                font.pointSize: 7
                Layout.fillWidth: true
            }

        }
      } } }

        Item {
            id: brightnessItem
            Layout.fillWidth: true
            height: 40
            visible: brightness.enabled

            Rectangle {
                id: brightnessItemBg
                anchors.fill: parent
                color: FishUI.Theme.darkMode ? "#AEAEAE" : "white"
                radius: FishUI.Theme.bigRadius
                opacity: 0.8
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

//                Label {
//                    text: brightnessSlider.value + "%"
//                    color: FishUI.Theme.disabledTextColor
//                    Layout.preferredWidth: _fontMetrics.advanceWidth("100%")
//                }
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
                color: FishUI.Theme.darkMode ? "#AEAEAE" : "white"
                radius: FishUI.Theme.bigRadius
                opacity: 0.8
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
                    to: PulseAudio.NormalVolume

                    stepSize: to / (to / PulseAudio.NormalVolume * 100.0)

                    value: defaultSink ? defaultSink.volume : 0

                    onValueChanged: {
                        if (!defaultSink)
                            return

                        defaultSink.volume = value
                        defaultSink.muted = (value === 0)
                    }
                }

//                Label {
//                    text: parseInt(volumeSlider.value / PulseAudio.NormalVolume * 100.0) + "%"
//                    Layout.preferredWidth: _fontMetrics.advanceWidth("100%")
//                    color: FishUI.Theme.disabledTextColor
//                }
            }
        }
        MprisItem {
            height: 96
            Layout.fillWidth: true
        }

        FontMetrics {
            id: _fontMetrics
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
       /* Item {
            id: topItem
            Layout.fillWidth: true
            height: 32

            RowLayout {
                id: topItemLayout
                anchors.fill: parent
                anchors.rightMargin: FishUI.Units.largeSpacing
                spacing: FishUI.Units.largeSpacing

                Label {
                    leftPadding: FishUI.Units.largeSpacing
                    text: qsTr("Control Center")
                    font.bold: true
                    font.pointSize: 14
                    Layout.fillWidth: true
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
        }*/
    }

    function calcExtraSpacing(cellSize, containerSize) {
        var availableColumns = Math.floor(containerSize / cellSize)
        var extraSpacing = 0
        if (availableColumns > 0) {
            var allColumnSize = availableColumns * cellSize
            var extraSpace = Math.max(containerSize - allColumnSize, 0)
            extraSpacing = extraSpace / availableColumns
        }
        return Math.floor(extraSpacing)
    }
}
