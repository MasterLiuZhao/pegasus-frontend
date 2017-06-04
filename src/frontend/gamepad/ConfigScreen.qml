// Pegasus Frontend
// Copyright (C) 2017  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import "preview" as GamepadPreview
import QtQuick 2.8
import QtGamepad 1.0

FocusScope {
    property bool hasGamepads: GamepadManager.connectedGamepads.length > 0

    signal screenClosed()

    width: parent.width
    height: parent.height
    visible: x < parent.width

    property real escapeDelay: 2000
    property real escapeStartTime: 0
    property real escapeProgress: 0

    Timer {
        id: escapeTimer
        interval: 50
        repeat: true
        onTriggered: {
            var currentTime = new Date().getTime();
            escapeProgress = (currentTime - escapeStartTime) / escapeDelay;

            if (escapeProgress > 1.0) {
                stopEscapeTimer();
                screenClosed();
            }
        }
    }

    function stopEscapeTimer() {
        escapeTimer.stop();
        escapeStartTime = 0;
        escapeProgress = 0;
    }

    Keys.onEscapePressed: {
        if (!event.isAutoRepeat) {
            escapeStartTime = new Date().getTime();
            escapeTimer.start();
        }
    }
    Keys.onReleased: {
        if (event.key === Qt.Key_Escape && !event.isAutoRepeat) {
            stopEscapeTimer();
        }
    }


    Gamepad {
        id: gamepad
        deviceId: -1
    }

    Rectangle {
        id: deviceSelect
        width: parent.width
        height: rpx(70)
        color: "#333"
        anchors.top: parent.top

        focus: true
        Keys.forwardTo: [gamepadList]
        KeyNavigation.down: configL1

        GamepadName {
            visible: !hasGamepads
            highlighted: deviceSelect.focus
            text: qsTr("No gamepads connected")
        }

        ListView {
            id: gamepadList
            anchors.fill: parent

            clip: true
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 300
            orientation: ListView.Horizontal

            // FIXME: it seems Qt 5.8 can't list the connected gamepads
            // model: GamepadManager.connectedGamepads
            model: GamepadManager.connectedGamepads.length

            onCurrentIndexChanged: {
                gamepad.deviceId = GamepadManager.connectedGamepads.length > currentIndex
                                 ? GamepadManager.connectedGamepads[currentIndex] : -1
            }

            delegate: Item {
                width: ListView.view.width
                height: ListView.view.height

                GamepadName {
                    // FIXME: it seems Qt 5.8 doesn't know the name of the gamepad
                    text: "Gamepad name here #" + (index + 1)
                    highlighted: deviceSelect.focus
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        color: "#222"
        anchors {
            top: deviceSelect.bottom
            bottom: parent.bottom
        }
    }

    FocusScope {
        id: layoutArea
        width: parent.width
        anchors {
            top: deviceSelect.bottom
            bottom: footer.top; bottomMargin: rpx(10)
        }

        property int horizontalOffset: rpx(-560)
        property int verticalSpacing: rpx(170)

        onActiveFocusChanged:
            if (!activeFocus) padPreview.currentButton = ""

        ConfigGroup {
            groupName: qsTr("left back")
            anchors {
                left: parent.horizontalCenter
                leftMargin: parent.horizontalOffset
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -parent.verticalSpacing
            }

            ConfigField {
                focus: true
                id: configL1
                text: qsTr("shoulder")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "l1"

                KeyNavigation.right: configR1
                KeyNavigation.down: configL2
            }
            ConfigField {
                id: configL2
                text: qsTr("trigger")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "l2"

                KeyNavigation.right: configR2
                KeyNavigation.down: configDpadUp
            }
        }

        ConfigGroup {
            groupName: qsTr("dpad")
            anchors {
                left: parent.horizontalCenter
                leftMargin: parent.horizontalOffset
                verticalCenter: parent.verticalCenter
            }

            ConfigField {
                id: configDpadUp
                text: qsTr("up")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "dpup"

                KeyNavigation.right: configA
                KeyNavigation.down: configDpadLeft
            }
            ConfigField {
                id: configDpadLeft
                text: qsTr("left")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "dpleft"

                KeyNavigation.right: configB
                KeyNavigation.down: configDpadRight
            }
            ConfigField {
                id: configDpadRight
                text: qsTr("right")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "dpright"

                KeyNavigation.right: configX
                KeyNavigation.down: configDpadDown
            }
            ConfigField {
                id: configDpadDown
                text: qsTr("down")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "dpdown"

                KeyNavigation.right: configY
                KeyNavigation.down: configLeftStickX
            }
        }

        ConfigGroup {
            groupName: qsTr("left stick")
            anchors {
                left: parent.horizontalCenter
                leftMargin: parent.horizontalOffset
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: parent.verticalSpacing
            }

            ConfigField {
                id: configLeftStickX
                text: qsTr("x axis")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "lx"

                KeyNavigation.right: configRightStickX
                KeyNavigation.down: configLeftStickY
            }
            ConfigField {
                id: configLeftStickY
                text: qsTr("y axis")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "ly"

                KeyNavigation.right: configRightStickY
                KeyNavigation.down: configL3
            }
            ConfigField {
                id: configL3
                text: qsTr("press")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "l3"

                KeyNavigation.right: configR3
            }
        }

        ConfigGroup {
            groupName: qsTr("right back")
            alignRight: true
            anchors {
                right: parent.horizontalCenter
                rightMargin: parent.horizontalOffset
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -parent.verticalSpacing
            }

            ConfigField {
                id: configR1
                text: qsTr("shoulder")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "r1"

                KeyNavigation.up: deviceSelect
                KeyNavigation.down: configR2
            }
            ConfigField {
                id: configR2
                text: qsTr("trigger")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "r2"

                KeyNavigation.down: configA
            }
        }

        ConfigGroup {
            groupName: qsTr("abxy")
            alignRight: true
            anchors {
                right: parent.horizontalCenter
                rightMargin: parent.horizontalOffset
                verticalCenter: parent.verticalCenter
            }

            ConfigField {
                id: configA
                text: "a"
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "a"

                KeyNavigation.down: configB
            }
            ConfigField {
                id: configB
                text: "b"
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "b"

                KeyNavigation.down: configX
            }
            ConfigField {
                id: configX
                text: "x"
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "x"

                KeyNavigation.down: configY
            }
            ConfigField {
                id: configY
                text: "y"
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "y"

                KeyNavigation.down: configRightStickX
            }
        }

        ConfigGroup {
            groupName: qsTr("right stick")
            alignRight: true
            anchors {
                right: parent.horizontalCenter
                rightMargin: parent.horizontalOffset
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: parent.verticalSpacing
            }

            ConfigField {
                id: configRightStickX
                text: qsTr("x axis")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "rx"

                KeyNavigation.down: configRightStickY
            }
            ConfigField {
                id: configRightStickY
                text: qsTr("y axis")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "ry"

                KeyNavigation.down: configR3
            }
            ConfigField {
                id: configR3
                text: qsTr("press")
                onActiveFocusChanged:
                    if (activeFocus) padPreview.currentButton = "r3"
            }
        }

        GamepadPreview.Container {
            id: padPreview
            gamepad: gamepad
        }
    }

    Item {
        id: footer
        width: parent.width
        height: rpx(50)
        anchors.bottom: parent.bottom

        Rectangle {
            width: parent.width * 0.97
            height: rpx(1)
            color: "#777"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Canvas {
            width: backButtonIcon.width + rpx(4)
            height: width
            anchors.centerIn: backButtonIcon

            property real progress: escapeProgress
            onProgressChanged: requestPaint()

            onPaint: {
                var ctx = getContext('2d');
                ctx.clearRect(0, 0, width, height);

                var center = width / 2;
                var startAngle = -Math.PI / 2

                ctx.beginPath();
                ctx.fillStyle = "#eee";
                ctx.moveTo(center, center);
                ctx.arc(center, center, center,
                        startAngle, startAngle + Math.PI * 2 * progress, false);
                ctx.fill();
            }
        }

        // TODO: replace this with an SVG icon
        Rectangle {
            id: backButtonIcon
            height: label.height
            width: height
            radius: width * 0.5
            border { color: "#777"; width: rpx(1) }
            color: "transparent"

            anchors {
                right: label.left
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: rpx(1)
                margins: rpx(10)
            }

            Text {
                text: "B"
                color: "#777"
                font {
                    family: "Roboto"
                    pixelSize: parent.height * 0.7
                }
                anchors.centerIn: parent
            }
        }

        Text {
            id: label
            text: qsTr("hold down to quit")
            verticalAlignment: Text.AlignTop

            color: "#777"
            font {
                family: "Roboto"
                pixelSize: rpx(22)
                capitalization: Font.SmallCaps
            }
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: rpx(-1)
                right: parent.right; rightMargin: parent.width * 0.015
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: screenClosed()
    }
}
