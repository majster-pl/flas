import QtQuick 2.0
import Ubuntu.Components 1.3

ListItem {
    id: headerListItem
    height: getHeight()
//    property alias currentSelection: mainPage.header.sections.selectedIndex
    property string msgText
    property int curSelection

    color: UbuntuColors.blue

    Connections {
        target: mainPage.header.sections
        onSelectedIndexChanged: {
            curSelection = mainPage.header.sections.selectedIndex
            if (mainPage.header.sections.selectedIndex === 0) {
//                print("TOP50")
                msgText = i18n.tr("Pull down to refrash the list.")
            } else if (mainPage.header.sections.selectedIndex === 1){
//                print("Local")
                msgText = i18n.tr("Local station are based on your IP address.")
            } else if (mainPage.header.sections.selectedIndex === 2) {
                print("Recomended")
            }
        }
    }

    function getHeight() {
        if(settings.top50Tip && (mainPage.header.sections.selectedIndex == 0)) {
            return label1.height + units.gu(2)
        } else if(settings.localTip && (mainPage.header.sections.selectedIndex == 1)) {
            return label1.height + units.gu(2)
        } else if (settings.recomendedTip && (mainPage.header.sections.selectedIndex == 2)){
            return label1.height + units.gu(2)
        } else {
            return 0
        }
     }

    function getText() {
        switch (mainPage.header.sections.selectedIndex) {
        case 0:
            return i18n.tr("Swipe left on the radio for more options.")
//            break
        case 1:
            return i18n.tr("Local stations are based on your IP address.")
//            break
        case 2:
            return i18n.tr("Pull down to refresh the list.")
        }
    }

    Behavior on height {
        UbuntuNumberAnimation {}
    }
    SlotsLayout {
        padding {
            top: units.gu(1)
            bottom: units.gu(1)
        }

        // hint icon
        Icon {
            name: "torch-on"
            color: "white"
            SlotsLayout.position: SlotsLayout.Leading;
            width: units.gu(2)
        }

        // text
        mainSlot: Label {
            id: label1
            width: parent.width - units.gu(12)
            color: "white"
            wrapMode: Text.Wrap
            text: getText()
        }
        AbstractButton {
            height: units.gu(2)
            width: height
            SlotsLayout.position: SlotsLayout.Trailing
            Rectangle {
                anchors.fill: parent
                anchors.margins: -units.gu(1)
                color: mouseArea.pressed ? UbuntuColors.lightGrey : "transparent"
            }

            Icon {
                name: "close"
                width: units.gu(2)
                color: "white"
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                anchors.margins: -units.gu(1)
                onClicked: {
                    switch (mainPage.header.sections.selectedIndex) {
                    case 0:
                        settings.top50Tip = false
                        break;
                    case 1:
                        settings.localTip = false
                        break;
                    case 2:
                        settings.recomendedTip = false
                    }
                }

            }

        }

    }



//    }
}
