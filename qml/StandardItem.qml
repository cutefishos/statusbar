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
import QtGraphicalEffects 1.0

import FishUI 1.0 as FishUI
import Cutefish.StatusBar 1.0

Item {
    id: control

    property real moveX: 0
    property real moveY: 0

    property string popupText: ""

    property bool checked: false
    property bool animationEnabled: false

    signal clicked
    signal rightClicked

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onEntered: {
            _bgRect.x = mouseX
            _bgRect.y = mouseY
            _bgRect.state = "shown"
        }

        onExited: {
            control.moveX = mouseX
            control.moveY = mouseY
            _bgRect.state = "hidden"
        }

        onClicked: {
            if (mouse.button == Qt.LeftButton)
                control.clicked()
            else if (mouse.button == Qt.RightButton)
                control.rightClicked()
        }

        onPressed: {
            popupTips.hide()
        }

        onContainsMouseChanged: {
            if (containsMouse && control.popupText !== "") {
                popupTips.popupText = control.popupText
                popupTips.position = Qt.point(control.mapToGlobal(0, 0).x + (control.width / 2 - popupTips.width / 2),
                                              control.height + FishUI.Units.smallSpacing)
                popupTips.show()
            } else {
                popupTips.hide()
            }
        }
    }

    Rectangle {
        id: _bgRect
        radius: FishUI.Theme.smallRadius

        state: "hidden"
        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: _bgRect
                    x: 0
                    y: 1
                    width: control.width
                    height: control.height - 2
                    visible: true
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: _bgRect
                    x: control.moveX
                    y: control.moveY
                    width: 0
                    height: 0
                    visible: false
                }
            }
        ]

        transitions:[
            Transition {
                from: "hidden"
                to: "shown"

                SequentialAnimation{
                    PropertyAnimation {
                        target: _bgRect
                        properties: "visible"
                        duration: 0
                        easing.type: Easing.OutQuart
                    }
                    PropertyAnimation {
                        target: _bgRect
                        properties: "x, y, width, height"
                        duration: control.animationEnabled ? 400 : 0
                        easing.type: Easing.OutQuart
                    }
                }
            },
            Transition {
                from: "shown"
                to: "hidden"

                SequentialAnimation{
                    PropertyAnimation {
                        target: _bgRect
                        properties: "x, y, width, height"
                        duration: control.animationEnabled ? 200 : 0
                        easing.type: Easing.OutQuart
                    }
                    PropertyAnimation {
                        target: _bgRect
                        properties: "visible"
                        duration: 0
                        easing.type: Easing.OutQuart
                    }
                }
            }
        ]

        color: {
            if (control.checked) {
                return (rootItem.darkMode) ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.1)
            }

            if (_mouseArea.containsPress)
                return (rootItem.darkMode) ? Qt.rgba(255, 255, 255, 0.3) : Qt.rgba(0, 0, 0, 0.2)
            else
                return (rootItem.darkMode) ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.1)
        }
    }
}
