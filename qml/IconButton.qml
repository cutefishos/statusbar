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
import QtQuick.Layouts 1.12
import FishUI 1.0 as FishUI

Item {
    id: control

    property url source
    property bool checked: false
    property real size: 24
    property string popupText

    signal leftButtonClicked
    signal rightButtonClicked
    signal clicked
    signal pressAndHold
    property var backgroundColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1)
                                                         : Qt.rgba(0, 0, 0, 0.05)
     property var hoverColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.15)
                                                    : Qt.rgba(0, 0, 0, 0.1)
     property var pressedColor: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.2)
                                                      : Qt.rgba(0, 0, 0, 0.15)

     property var highlightHoverColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.highlightColor, 1.1)
                                                             : Qt.darker(FishUI.Theme.highlightColor, 1.1)
     property var highlightPressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.highlightColor, 1.1)
                                                               : Qt.darker(FishUI.Theme.highlightColor, 1.2)



    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: control.visible ? true : false

        onClicked: {
            if (mouse.button === Qt.LeftButton)
                control.leftButtonClicked()
            else if (mouse.button === Qt.RightButton)
                control.rightButtonClicked()
        }
        onPressAndHold: {
            control.pressAndHold()
        }
    }


    Rectangle {
        anchors.fill: parent
        // radius: parent.height * 0.2
       //radius: parent.height / 2
        radius: height/2
       /* color: {
            if (mouseArea.containsMouse) {
                if (mouseArea.containsPress)
                    return (FishUI.Theme.darkMode) ? Qt.rgba(255, 255, 255, 0.3) : Qt.rgba(0, 0, 0, 0.2)
                else
                    return (FishUI.Theme.darkMode) ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.1)
            }

            return "transparent"
        }*/
        color: {
            if (control.checked) {
                if (mouseArea.pressed)
                    return highlightPressedColor
                else if (mouseArea.containsMouse)
                    return highlightHoverColor
                else
                    return FishUI.Theme.highlightColor
            } else {
                if (mouseArea.pressed)
                    return pressedColor
                else if (mouseArea.containsMouse)
                    return hoverColor
                else
                    return backgroundColor
            }
        }
    }

    Image {
        id: iconImage
        anchors.centerIn: parent
        width:22
        height:22
        sourceSize.width:22
        sourceSize.height:22
        source: control.source
        asynchronous: true
        antialiasing: true
        smooth: false
    }
}

