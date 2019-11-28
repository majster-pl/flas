/*
 * Copyright (C) 2014 Szymon Waliczek.
 *
 * Authors:
 *  Szymon Waliczek <majsterrr@gmail.com>
 *
 * This file is part of Jupiter Broadcasting application for Ubuntu Touch.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


import QtQuick 2.2
import Ubuntu.Components 1.3
//import Ubuntu.Components.ListItems 0.1
//import QtGraphicalEffects 1.0
//import Ubuntu.Components.Popups 1.3
import QtMultimedia 5.0
import QtGraphicalEffects 1.0 // for coloroverlay
//import "utils.js" as Utils


Rectangle {
    id: root

    width: parent.width
    height: units.gu(9)
    color: "transparent"
    x: parent.x
    y: parent.y
    clip: true

    property int playerHeight

    property alias barState: root.state

    state: "hiden"

//    onYChanged: print("tera Y jest:", y)




    // miliseconds to timestamp
    function seconds2time(seconds) {
        var start = new Date(1970, 1, 1, 24, 0, 0, 0).getTime();
        var end = new Date(1970, 1, 1, 0, 0, 0, parseInt(seconds)).getTime();
        var duration = end - start;
        return new Date(duration).toString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, "$1");
    }


//    onStateChanged: {
//        print(state)
//        if(state == "hiden") {
//            root.visible = false
//        } else {
//            root.visible = true
//        }
//    }



//    function isOpen() {
//        if(state === "open") return true
//    }


    // function to open/show top podcast info pane.
    function openBottomEdge() {
//        print("Showign bottom edge")
        root.state = "open"
    }
    // function to close/hide top podcast info pane.
    function minimizeBottomEdge() {
//        print("Closing bottom edge")
        root.state = "minimized"
    }

    // function to hide mediaPlayerBar in tablet mode.
    function hideMediaPlayer() {
//        print("hiding mediaPlayer")
        root.state = "hiden"
    }



    // states for mediaPlayer
    states: [
        // when hiden ( not visable at all )
        State {
            name: "hiden"
            PropertyChanges {
                target: root
                y: mainView.height
            }
            PropertyChanges {
                target: playerControlsHalf
                z: 0
            }

        },

        // when open ( navigation buttons + title + slider etc. )
        State {
            name: "open"
            PropertyChanges {
                target: root
                y: mainView.height - playerControlsHalf.height
            }
            PropertyChanges {
                target: playerToolBarMouseArea
                anchors.topMargin: units.gu(1)  // add mouse area to the top of hiden bar for better greap.
                z: 1
            }
            PropertyChanges {
                target: playerControlsHalf
                z: 0
            }
        },

        // small radio icon. radio name and share + play/stop button
        State {
            name: "minimized"
            PropertyChanges {
                target: root
                y: mainView.height - units.gu(3)
            }
            PropertyChanges {
                target: playerControlsHalf
                z: 0
            }

            PropertyChanges {
                target: playerToolBarMouseArea
                anchors.topMargin: units.gu(-1)  // add mouse area to the top of hiden bar for better greap.
            }
        }
    ]



    // animations
    transitions: Transition {
        from: "open,minimized,hiden"
        to: "open,minimized,hiden"
        NumberAnimation {
            duration: 200
            properties: "y,opacity"
        }
    }


    // State: OPEN
    // player opened ( half )
    Rectangle {
        id: playerControlsHalf
        height: units.gu(8)
        width: parent.width
        anchors.right: parent.right
        anchors.top: parent.top
        color: "black"
        opacity: 1

        Rectangle {
            width: parent.width
            height: units.gu(0.1)
            anchors.top: parent.top
            color: UbuntuColors.lightGrey
//            z: 40000
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {

                if(root.state === "minimized") {
                    openBottomEdge()
                } else {
//                    if(mainAdaptivePageLayout.)
                    Haptics.play()
                    mainRadioListView.currentIndex = -1
                    mainAdaptivePageLayout.addPageToNextColumn(mainPage, Qt.resolvedUrl("RadioMainPageNew.qml"))
                    radioMainPage.curentRadioPage = true
                }

            }

        }

        // Current station icon
        CrossFadeImage {
            id: radioIcon
            height: playerHeight - units.gu(0.2)
            width: height
            anchors.left: parent.left
            anchors.leftMargin: units.gu(0.1)
            anchors.top: parent.top
            anchors.topMargin: units.gu(0.1)
            fadeStyle: "overlay"
            fadeDuration: UbuntuAnimation.SlowDuration
            source: curRadioIcon
            onSourceChanged: {
                if(root.state === "minimized") {
                    openBottomEdge()
                }
            }

//            opacity: loadingStream ? 0.4 : 1
//            Behavior on opacity { UbuntuNumberAnimation {} }
        }




        // Station Name and current track (if available)
        Item {
            anchors {
                top: parent.top
                topMargin: units.gu(0.5)
                bottom: parent.bottom
                left: radioIcon.right
                leftMargin: units.gu(1)
                right: controlButtonsRow.left
                rightMargin: units.gu(1)
            }

            Column {
                width: parent.width
                spacing: units.gu(0.3)

                Marquee {
                    padding: 1
                    width: parent.width
                    text: curRadioName
                    labe.color: "white"
                    labe.font.bold: true
                    marqueeFontSize: "medium"
                    bgColor: "black"
                    textColor: UbuntuColors.warmGrey
                }

                Marquee {
                    padding: 1
                    width: parent.width
                    text: mediaHub.metaData.title
//                    text: mediaHub.metaData.title === undefined ? "" : mediaHub.metaData.title
                    marqueeFontSize: "medium"
                    textColor: UbuntuColors.warmGrey
                    labe.font.italic: true
                }

            }






        }


        Label {
//            width: parent.width

            anchors {
                top: parent.top; topMargin: units.gu(0.5)
                right: parent.right; rightMargin: units.gu(1.5)
            }
            fontSize: "medium"
            color: "white"
            text: seconds2time(mediaHub.position)
//                text: "DUPKA JASIA"
            z: parent.z + 1
            opacity: root.state === "open" ? (playerHeight / parent.height) : 0
            Behavior on opacity { UbuntuNumberAnimation {} }
        }


        Row {
            id: controlButtonsRow
            height: playerHeight
            anchors.right: parent.right
            anchors.rightMargin: units.gu(1)
            anchors.top: parent.top
            spacing: units.gu(2)

//            // share button
//            AbstractButton {
//                width: units.gu(3)
//                height: parent.height - units.gu(1)
//                anchors.verticalCenter: parent.verticalCenter
//                Icon {
//                    height: units.gu(2.5)
//                    width: height
//                    anchors.centerIn: parent
//                    name: "share"
//                    color: "white"
////                    Behavior on height { UbuntuNumberAnimation {} }sharePicker
//                }
//                onClicked: {
//                    var t = i18n.tr("I'm listening to %1 via fLAs on my Ubuntu Phone! You can listen online here: %2").arg(curRadioName).arg(curRadioSource)
//                    shareText(t)
//                }
//            }


            AbstractButton {
                width: units.gu(3)
                height: parent.height - units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                enabled: !loadingStream
                ActivityIndicator {
        //                width: parent.width - units.gu(0)
                    height:  parent.width - units.gu(0)
                    width: height
                    anchors.centerIn: parent
                    running: loadingStream
//                    running: true
//                    z: parent.z +100
                }
                Icon {
                    height: units.gu(3)
                    width: height
                    anchors.centerIn: parent
                    name: (((mediaHub.playbackState == MediaPlayer.PausedState) || (mediaHub.playbackState == MediaPlayer.StoppedState))
                           || (mediaHub.status == MediaPlayer.Stalled)) ? "media-playback-start" : "media-playback-pause"
                    color: "white"
//                    Behavior on height { UbuntuNumberAnimation {} }
                }
                onClicked: {
                    mediaHub.playOrPause()
//                    if(curRadioSource === "") {
//                        curRadioSource = tempCurRadioSource
//                    }

//                    if(mediaHub.playbackState === 0) {
//                        mediaHub.stop()
//                    } else {
//                        mediaHub.play()
//                    }
                }
            }
        }


    }


    /* Object which captures mouse drags to show/hide the toolbar */
    MouseArea {
        id: playerToolBarMouseArea
        anchors.fill: parent
        enabled: true
        property bool changed: false
        property int startContainerY: 0
        property int startMouseY: 0

        // Settings for dragging the container
        drag.axis: Drag.YAxis
        drag.maximumY: root.parent.height
        drag.minimumY: root.parent.height - playerControlsHalf.height
        drag.target: root

        propagateComposedEvents: true
        onClicked: mouse.accepted = changed  // pass clicked evented to children unless changed (YAxis)

        onMouseYChanged: {
            // Mouse has been accepted with YAxis changed and set changed to true
            mouse.accepted = true;
            changed = true;
        }

        onPressed: {
            mouse.accepted = false;  // mouse not accepted yet

            // Record starting positions for later
            startContainerY = root.y;
            startMouseY = mouse.y;

            // Restart autohide timer on mouse press inside toolbar
//                        startAutohideTimer();
        }

        onReleased: {
            mouse.accepted = changed;  // mouse is accepted if the YAxis has changed
            changed = false;  // reset changed

            var diff = root.y - startContainerY;
            if (diff > units.gu(2)) {
                minimizeBottomEdge();
            } else if (diff < -units.gu(2)) {
                openBottomEdge()
            } else {
                musicToolbarContainerReset.start();
            }
        }

        // On pressandhold reveal part of the toolbar as a hint
        NumberAnimation {
            id: musicToolbarContainerHintAnimation
            target: root
            property: "y"
            duration: 200
            to: root.parent.height - units.gu(1.5)
        }

        // Animation to reset the toolbar if it hasn't been dragged far enough
        NumberAnimation {
            id: musicToolbarContainerReset
            target: root
            property: "y"
            duration: 200
            to: playerToolBarMouseArea.startContainerY
        }
    }


//    // if app run for first time hide player
//    Component.onCompleted: {
//        if(String(lastRadioDB.contents.lastRadioArray) === "true") {
//            state = "hiden"
//        } else {
//            state = "open"
//        }
//    }



}
