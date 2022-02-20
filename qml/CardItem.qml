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

Item {
    id: control

    property bool checked: false
    property alias icon: _image.source
    property alias label: _titleLabel.text
    property alias label2:_titleLabel2.text

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
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: control.clicked()

        onPressAndHold: {
            control.pressAndHold()
        }
    }
    Label {
        id: _titleLabel2
        leftPadding: FishUI.Units.largeSpacing
        font.bold: true
        topPadding: 2
        font.pointSize: 10
        Layout.fillWidth: true
    }
  //  ColumnLayout {
    //    anchors.fill: parent
      //  anchors.leftMargin: FishUI.Theme.smallRadius
       // anchors.rightMargin: FishUI.Theme.smallRadius
       // spacing: FishUI.Units.largeSpacing
    RowLayout {
       // anchors.rightMargin: FishUI.Units.largeSpacing
        //anchors.leftMargin: FishUI.Theme.smallRadius
        //anchors.rightMargin: FishUI.Theme.smallRadius
        //spacing: FishUI.Units.largeSpacing
        Item {
            Layout.fillHeight: true
        }

        Item {
            Layout.preferredWidth: 12 + FishUI.Units.largeSpacing * 2
            Layout.preferredHeight: 12 + FishUI.Units.largeSpacing * 2

            Layout.alignment: Qt.AlignLeft

            Rectangle {
                anchors.fill: parent
                radius: height / 2
//                color: "#E5E5E5"

                color: {
                    if (control.checked) {
                        if (_mouseArea.pressed)
                            return highlightPressedColor
                        else if (_mouseArea.containsMouse)
                            return highlightHoverColor
                        else
                            return FishUI.Theme.highlightColor
                    } else {
                        if (_mouseArea.pressed)
                            return pressedColor
                        else if (_mouseArea.containsMouse)
                            return hoverColor
                        else
                            return backgroundColor
                    }
                }
            }
            Image {
                id: _image
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                Layout.alignment: Qt.AlignVCenter+Qt.AlignLeft
                anchors.centerIn: parent
                sourceSize: Qt.size(22, 22)
                asynchronous: true
                antialiasing: true
                smooth: true
            }
        }
        Label {
            id: _titleLabel
    //            color: control.checked ? FishUI.Theme.highlightedTextColor : FishUI.Theme.textColor
            Layout.preferredHeight:1
            Layout.alignment:Qt.AlignLeft
            topPadding: 20
            font.pointSize: 8
            visible: text
        }
        Item {
            Layout.fillHeight: true
        }
}
    }
