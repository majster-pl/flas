import QtQuick 2.0
import Ubuntu.Components 1.3

// tab2
Column {
    id: tab2

    clip: true
    Repeater {
        width: parent.width
        model: radioStreamMODELArray.recentTitles

        delegate: ListItem {
            height: trackNameLayout.height
            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "edit-copy"
                        onTriggered: print(currentTrackText(trackName))
                    },
                    Action {
                        iconName: "share"
//                                onTriggered: print(currentTrackText(trackName))
                        onTriggered: {
                            var t = i18n.tr("%1 I love this song! I found it via fLAs on my Ubuntu Phone!").arg(currentTrackText(trackName))
                            shareText(t)
                        }
                    }

                ]
            }
            ListItemLayout {
                id: trackNameLayout
                title.text: currentTrackText(trackName)
                title.font.italic: true
                Icon {
                    name: "audio-x-generic-symbolic"
                    SlotsLayout.position: SlotsLayout.Leading;
                    width: units.gu(1.5)
                }
                Icon {
                    width: units.gu(2)
                    name: "search"
                    SlotsLayout.position: SlotsLayout.Trailing
                }


            }


            onClicked: {
                Qt.openUrlExternally("scope://musicaggregator?q="+ trackName)
            }
        }
    }



    Item {
        width: parent.width
        height: mainRadioInfoListView.height - mainRadioInfoListView.headerItem.height
        visible: radioStreamMODELArray.recentTitles.count == 0
        clip: true

        Column {
            width: parent.width
            spacing: units.gu(1)
            anchors.verticalCenter: parent.verticalCenter
            Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: "audio-x-generic-symbolic"
                width: units.gu(5)
            }
            Label {
                width: parent.width
                wrapMode: Text.Wrap
                text: i18n.tr("No recent songs")
                horizontalAlignment: Text.AlignHCenter
                fontSize: "large"
            }
        }
    }

}
