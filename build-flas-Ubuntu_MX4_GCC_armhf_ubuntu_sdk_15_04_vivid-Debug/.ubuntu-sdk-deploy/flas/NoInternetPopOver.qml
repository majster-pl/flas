import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3


Dialog {
    id: dialogue
    title: "Save file"
    text: "Are you sure that you want to save this file?"
    Button {
        text: "cancel"
        onClicked: PopupUtils.close(dialogue)
    }
    Button {
        text: "overwrite previous version"
        color: UbuntuColors.orange
        onClicked: PopupUtils.close(dialogue)
    }
    Button {
        text: "save a copy"
        color: UbuntuColors.orange
        onClicked: PopupUtils.close(dialogue)
    }
}
