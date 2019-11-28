import QtQuick 2.0
import Ubuntu.Components 1.3

Column {
    id: tab1
    Item {
        width: parent.width
        height: 1
    }

    clip: true
    ListItem {
        width: parent.width
        height: layout1.height
        divider.visible: false
        visible: layout1.subtitle.text === "" ? false : true
        ListItemLayout {
            id: layout1
            width: parent.width
            title.text: ""
            subtitle.text: radioStreamMODELArray.status == 1 ? radioStreamMODELArray.model.get(0).description : ""
            subtitle.wrapMode: Text.Wrap
            subtitle.font.pixelSize: units.gu(2)
            subtitle.elide: Text.ElideNone
            subtitle.maximumLineCount: 10000
            Icon {
                name: "info"
                SlotsLayout.position: SlotsLayout.Leading;
                width: units.gu(2)
            }
        }
    }

    ListItem {
        width: parent.width
        height: layout2.height
        divider.visible: false
        visible: layout2.subtitle.text === "" ? false : true
        //                        Rectangle {
        //                            anchors.fill:
        //                        }

        ListItemLayout {
            id: layout2
            width: parent.width
            title.text: ""
            subtitle.text: radioStreamMODELArray.status == 1 ? radioStreamMODELArray.model.get(0).link : ""
            subtitle.wrapMode: Text.Wrap
            subtitle.font.pixelSize: units.gu(2)
            subtitle.font.underline: true
            subtitle.font.italic: true
            subtitle.color: UbuntuColors.blue
            subtitle.elide: Text.ElideNone
            subtitle.maximumLineCount: 10000
            Icon {
                name: "stock_link"
                SlotsLayout.position: SlotsLayout.Leading;
                width: units.gu(2)
            }

        }
        onClicked: {
            print("link:",radioStreamMODELArray.model.get(0).link)
        }
    }

}

