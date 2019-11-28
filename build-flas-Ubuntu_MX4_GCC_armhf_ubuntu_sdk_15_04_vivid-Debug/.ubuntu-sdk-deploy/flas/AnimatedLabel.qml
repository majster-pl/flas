import QtQuick 2.4
import Ubuntu.Components 1.3
//import "components"


Label {
    id: labelMain

    property string newText

    Behavior on opacity { UbuntuNumberAnimation {duration: 300} }

    onOpacityChanged: if(opacity === 0) labelMain.text = newText
    onNewTextChanged: labelMain.opacity = 0
    onTextChanged: labelMain.opacity = 1


}
