import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.0
//import "components"

ListItem {
    width: parent.width
    height: listItemLayout.height
    property string iconPath: pathToShare +id+ ".png"

    function currentTrackText(text) {
        if (text === "" || text === "#") {
            return ""
        } else {
            return "<i>"+ text.replace(/&amp;/g, "&") + "</i>"
        }
    }

    color: mainAdaptivePageLayout.columns == 2 && mainRadioListView.currentIndex === index ? UbuntuColors.blue : theme.palette.normal.field

    onColorChanged: {
        if(color === "#E0E0E0") mainRadioListView.currentIndex = index
    }

    Behavior on color {
        ColorAnimation {}
    }

    JSONListModel {
        id: radioStreamMODEL
//        query: "$.streamUrls[*]"
    }

    trailingActions: ListItemActions {

        actions: [
            Action {
                iconName: ((mediaHub.playbackState == 1) && (id === curRadioId )) ? "media-playback-pause" : "media-playback-start"
                enabled: radioStreamMODEL.status == 1 ? true : false
                visible: (curRadioId !== 0 && curRadioId === id) ? false : true
                onTriggered: {
                    curRadioName = listItemLayout.title.text
                    curRadioIcon = icon.source.toString()
                    curRadioId = id
                    curRadioSource = radioStreamMODEL.model.get(0).streamUrl
                }
            },
            Action {
                iconName: favoritesListModel.isFavorite(id) ? "starred" : "non-starred"
                enabled: radioStreamMODEL.status == 1 ? true : false
                onTriggered: {
                    if(favoritesListModel.isFavorite(id)) {
                        favoritesListModel.removeRadio(id)
                    } else {
                        favoritesListModel.add(id, listItemLayout.title.text
                                               ,iconPath, radioStreamMODEL.model.get(0).streamUrl)
                    }
                }
            }

        ]
    }

    // load radio details on swiped
    onSwipedChanged: {
        if(swiped) {
            print("List item SWIPED!")
            radioStreamMODEL.source = "http://www.rad.io/info/broadcast/getbroadcastembedded?broadcast=" + id
            radioStreamMODEL.query = "$.streamUrls[*]"
//            radioStreamMODEL.query = "$"


        }
    }


    ListItemLayout {
        id: listItemLayout

        title.font.bold: true
        title.text: name
        title.color: mainAdaptivePageLayout.columns == 2 && mainRadioListView.currentIndex === index ? "black" : theme.palette.normal.activityText
        subtitle.text: currentTrackText(currentTrack)
        subtitle.color: mainAdaptivePageLayout.columns == 2 && mainRadioListView.currentIndex === index ? UbuntuColors.darkGrey : theme.palette.normal.baseText


        AbstractButton {
            id: playButton

            SlotsLayout.position: SlotsLayout.Trailing;
            height: units.gu(4)
            width: units.gu(4)
            visible: id === curRadioId
            enabled: !loadingStream

            Icon {
                width: parent.width
                anchors.centerIn: parent
                name: (mediaHub.playbackState == MediaPlayer.PlayingState) ? "media-playback-pause" : "media-playback-start"
                color: mainAdaptivePageLayout.columns == 2 && mainRadioListView.currentIndex === index ? theme.palette.normal.field : theme.palette.normal.raised
//                color: UbuntuColors.coolGrey
            }
            onClicked: {
                mediaHub.playOrPause()
            }

        }


        Image {
            id: icon
            height: units.gu(6)
            width: height
            SlotsLayout.position: SlotsLayout.Leading
            fillMode: Image.PreserveAspectFit
//            onSourceChanged: print(source)
            Component.onCompleted: source = iconPath
            property bool cached: false
            property bool imageError: false

            onStatusChanged: {
//                print("STATUS IS:", status)
                if(status === Image.Error) {
                    if(imageError) {
                        source = Qt.resolvedUrl("flas.png")
                    } else {
                        if(picture1Name === "") {
                            source = pictureBaseURL + "1/c100.png"
                        } else {
                            source = pictureBaseURL + "c100.png"
                        }
                        imageError = true
                        cached = true

                    }

                } else if (status === Image.Ready) {
//                    if(currentPlayingRadioId === id) mainRadioListView.currentIndex = index
                    if(index+1 === jsonModel.model.count) {
                        isLoaded = true
                    }

                    if(cached) {
                        icon.grabToImage(function(result) {
                            result.saveToFile(iconPath)
                        });
                    }
                    isLoaded = true

                }
            }


        }




    }


    onClicked: {
        mainPage.pageStack.addPageToNextColumn(mainPage, radioMainPage)
        mainRadioListView.currentIndex = index
        radioMainPage.curentRadioPage = false
    }


}
