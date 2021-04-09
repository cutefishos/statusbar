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
    width: 500
    height: _mainLayout.implicitHeight + FishUI.Units.largeSpacing * 4

    minimumWidth: 500
    maximumWidth: 500
    minimumHeight: _mainLayout.implicitHeight + FishUI.Units.largeSpacing * 4
    maximumHeight: _mainLayout.implicitHeight + FishUI.Units.largeSpacing * 4

    property var margin: 4 * FishUI.Units.devicePixelRatio
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

    FishUI.RoundedRect {
        id: _background
        anchors.fill: parent
        radius: control.height * 0.05
        color: FishUI.Theme.backgroundColor
        backgroundOpacity: FishUI.Theme.darkMode ? 0.3 : 0.4
    }

    FishUI.WindowShadow {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        radius: _background.radius
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.largeSpacing * 2
        anchors.topMargin: FishUI.Units.largeSpacing * 1.5
        anchors.rightMargin: FishUI.Units.largeSpacing * 2
        anchors.bottomMargin: FishUI.Units.largeSpacing
        spacing: FishUI.Units.largeSpacing

        Item {
            id: topItem
            Layout.fillWidth: true
            height: 50

            RowLayout {
                id: topItemLayout
                anchors.fill: parent
                spacing: FishUI.Units.largeSpacing

                Image {
                    id: userIcon
                    Layout.fillHeight: true
                    width: height
                    sourceSize: Qt.size(width, height)
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
            id: controlItem
            Layout.fillWidth: true
            height: 120
            visible: wirelessItem.visible || bluetoothItem.visible

            RowLayout {
                anchors.fill: parent
                spacing: FishUI.Units.largeSpacing

                CardItem {
                    id: wirelessItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width / 3 - FishUI.Units.largeSpacing * 2
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/network-wireless-connected-100.svg"
                                                         : "qrc:/images/light/network-wireless-connected-100.svg"
                    visible: network.wirelessHardwareEnabled
                    checked: network.wirelessEnabled
                    label: qsTr("Wi-Fi")
                    text: network.wirelessEnabled ? network.wirelessConnectionName ?
                                                        network.wirelessConnectionName :
                                                        qsTr("On") : qsTr("Off")
                    onClicked: network.wirelessEnabled = !network.wirelessEnabled
                }

                CardItem {
                    id: bluetoothItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width / 3 - FishUI.Units.largeSpacing * 2
                    icon: FishUI.Theme.darkMode || checked ? "qrc:/images/dark/bluetooth-symbolic.svg"
                                                         : "qrc:/images/light/bluetooth-symbolic.svg"
                    checked: false
                    label: qsTr("Bluetooth")
                    text: qsTr("Off")
                }

                CardItem {
                    id: darkModeItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width / 3 - FishUI.Units.largeSpacing * 2
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

        Item {
            id: brightnessItem
            Layout.fillWidth: true
            height: 50
            visible: brightness.enabled

            FishUI.RoundedRect {
                id: brightnessItemBg
                anchors.fill: parent
                anchors.margins: 0
                radius: FishUI.Theme.bigRadius
                color: FishUI.Theme.backgroundColor
                backgroundOpacity: 0.3
            }

            RowLayout {
                anchors.fill: brightnessItemBg
                anchors.margins: FishUI.Units.largeSpacing
                spacing: FishUI.Units.largeSpacing

                Image {
                    width: parent.height * 0.6
                    height: parent.height * 0.6
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/brightness.svg"
                }

                Slider {
                    id: brightnessSlider
                    from: 0
                    to: 100
                    stepSize: 1
                    value: brightness.value
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onMoved: {
                        brightness.setValue(brightnessSlider.value)
                    }
                }
            }
        }

        Item {
            id: volumeItem
            Layout.fillWidth: true
            height: 50
            visible: volume.isValid

            FishUI.RoundedRect {
                id: volumeItemBg
                anchors.fill: parent
                anchors.margins: 0
                radius: FishUI.Theme.bigRadius
                color: FishUI.Theme.backgroundColor
                backgroundOpacity: 0.3
            }

            RowLayout {
                anchors.fill: volumeItemBg
                anchors.margins: FishUI.Units.largeSpacing
                spacing: FishUI.Units.largeSpacing

                Image {
                    width: parent.height * 0.6
                    height: parent.height * 0.6
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
            Label {
                id: timeLabel

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
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                }
            }
        }
    }
}
