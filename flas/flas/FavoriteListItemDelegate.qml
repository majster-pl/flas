import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.0
//import "components"

ListItem {
    width: parent.width
    height: units.gu(8)
    clip: true
    property string iconPath: pathToShare +radioId+ ".png"

    function currentTrackText(text) {
        if (text === "" || text === "#") {
            return ""
        } else {
            return "<i>"+ text.replace("&", "&amp;") + "</i>"
        }
    }

//    color: mainRadioListView.currentIndex === index ? "#E0E0E0" : "white"
    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                name: i18n.tr("Delete")
                onTriggered: favoritesListModel.removeRadio(radioId)
            }
        ]
    }

    JSONListModel {
        id: radioStreamMODEL
        isArray: true

        onStatusChanged: {
            if(status == 1) {
                icon.source = radioStreamMODEL.model.get(0).pictureBaseURL + String(radioStreamMODEL.model.get(0).picture1Name).replace("t","c")
            }
        }
    }


    ListItemLayout {
        title.font.bold: true
        title.text: radioName
//        subtitle.text: currentTrackText(currentTrack)

        AbstractButton {
            id: playButton

            SlotsLayout.position: SlotsLayout.Trailing;
            height: units.gu(4)
            width: units.gu(4)
//            visible: radioId === curRadioId


            Icon {
                width: parent.width
                anchors.centerIn: parent
                name: (mediaHub.playbackState == MediaPlayer.PlayingState) && (radioId === curRadioId) ?
                          "media-playback-pause" : "media-playback-start"

                color: UbuntuColors.coolGrey
            }
            onClicked: {
                curRadioSource = streamUrl
                curRadioName = radioName
                curRadioIcon = icon.source.toString()
                curRadioId = radioId
//                mediaHub.play()
//                if(mediaHub.playbackState === MediaPlayer.PlayingState) {
//                    mediaHub.stop()
//                } else {
//                    mediaHub.play()
//                }
            }

        }


        Image {
            id: icon
            height: units.gu(6)
            width: height
            SlotsLayout.position: SlotsLayout.Leading
            fillMode: Image.PreserveAspectFit
            source: iconPath

            onStatusChanged: {
                if(status === Image.Error) {
                    radioStreamMODEL.source = "http://www.rad.io/info/broadcast/getbroadcastembedded?broadcast=" + radioId
                    radioStreamMODEL.query = "$"
                }
            }
        }

    }


    onClicked: {
        curRadioSource = streamUrl
        curRadioName = radioName
        curRadioIcon = icon.source.toString()
        curRadioId = radioId
    }


}
