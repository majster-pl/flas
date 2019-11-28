import QtQuick 2.4
import Ubuntu.Components 1.3


Item {
    id: root
//    width: parent.width
    height: marqueeText.height + padding
    clip: true

    // text to be displayed by the Marquee
    property string text

    property alias labe: marqueeText

    // top/bottom text padding
    property int padding : 10

    // the font size used by the Marquee ( "xx-small", "x-small", "small", "medium", "large", "x-large")
    property string marqueeFontSize : "large"

    // the scrolling animation speed
    property int scrollingSpeed : 8

    // pouse in scrolling time in ms
    property int pauseTime: 2000

    // the text color
    property color textColor: "black"

    // color of the listview BG
    property color bgColor: "transparent"

    // stopAnimationOnClick
    property bool stopOnClick: false

    onTextChanged: marqueeText.x = 0

    Label {
        id: marqueeText
        anchors.verticalCenter: parent.verticalCenter
//        font.pointSize: fontSize
        fontSize: marqueeFontSize
        color: textColor
        text: root.text
        x: 0

        SequentialAnimation on x {
            id: xAnim
            running: marqueeText.width < root.width ? false : true
            loops: Animation.Infinite // The animation is set to loop indefinitely
            PauseAnimation { duration: pauseTime } // pausa before scrolling
            NumberAnimation { from: 0; to: -(marqueeText.width - root.width); duration: marqueeText.width * scrollingSpeed/*; easing.type: Easing.InOutQuad*/ }
            PauseAnimation { duration: pauseTime } // brake in the end of the scrooling
            NumberAnimation { from: -(marqueeText.width - root.width); to: 0; duration: 500; easing.type: Easing.InOutQuad }
        }

    }

    // left shadeder
    Rectangle {
        height: width
        width: parent.height
        opacity: marqueeText.x >= 0 ? 0 : 1
        rotation: 90
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: bgColor }
        }
        Behavior on opacity {
            NumberAnimation {

            }
        }
    }


    //right shadder
    Rectangle {
        height: width
        width: parent.height
        anchors.right: parent.right
        rotation: 90
        opacity: marqueeText.x <= -(marqueeText.width - root.width + units.gu(0)) ? 0 : 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: bgColor }
            GradientStop { position: 1.0; color: "transparent" }
        }
        Behavior on opacity {
            NumberAnimation {

            }
        }

    }


    MouseArea {
        anchors.fill: parent
        visible: stopOnClick
        onClicked: {
            xAnim.paused === false ? xAnim.pause() : xAnim.resume()
        }
    }

}
