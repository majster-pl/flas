import QtQuick 2.4
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

//import "components"

Page {
    id: root

    property int currentIndexSelected: -1
    property string iconUrl: bgImage.source
    property ListModel curentListModel: mainRadioListView.model === jsonModel.model ? jsonModel.model : searchListModel.model
    property var currentIndexModel: mainRadioListView.model === jsonModel.model ? jsonModel.model.get(mainRadioListView.currentIndex) :
                                                                                  searchListModel.model.get(mainRadioListView.currentIndex)
    clip: true
    //    anchors.fill: parent // wierd white bar on the right without this ?
    //    anchors.rightMargin: units.gu(-0.1) // wierd white bar on the right without this ?

    // function to load picture (this can and even should be improved in the future...)
    function getImageSource(loadStatus) {
        if(loadStatus === 3) {
            return Qt.resolvedUrl("flas.png")
        } else if(currentIndexModel.picture1Name === "") {
            return (currentIndexModel.pictureBaseURL + "1/c100.png")
        } else {
            return (currentIndexModel.pictureBaseURL + "c100.png")
        }
    }

    function currentTrackText(textToConvert) {
        print("track:", textToConvert)
        if (textToConvert === "" || textToConvert === "#") {
            return ""
        } else {
            return textToConvert.replace(/&amp;/g, "&")
        }
    }

    header: PageHeader {
        title: mainRadioListView.currentIndex === -1 ? "" : currentIndexModel.name
        flickable: null
        //        sections.model: [i18n.tr("Top 50"), i18n.tr("Local"), i18n.tr("Recommended")]

        extension: Sections {
            id: radioInfoSelections
            width: parent.width
            //            anchors.horizontalCenter: parent.horizontalCenter
            actions: [
                Action {
                    text: "About"
                    onTriggered: currentIndexSelected = 0
                },
                Action {
                    text: "Recent Songs"
                    onTriggered: currentIndexSelected = 1;
                },
                Action {
                    text: "Co tam!"
                    onTriggered: currentIndexSelected = 2
                }
            ]
        }

        trailingActionBar.actions: [
            Action {
                iconName: favoritesListModel.isFavorite(currentIndexModel.id) ? "starred" : "non-starred"
                text: "Add to Favorites"
                onTriggered: {
                    if(favoritesListModel.isFavorite(currentIndexModel.id)) {
                        favoritesListModel.removeRadio(currentIndexModel.id)
                    } else {
                        favoritesListModel.add(currentIndexModel.id, currentIndexModel.name
                                               ,iconUrl, radioStreamMODEL.model.get(0).streamUrl)
                    }
                }
            },
            Action {
                iconName: "share"
                text: i18n.tr("Share")
                onTriggered: {
                    var t
                    if(curRadioId === currentIndexModel.id) {
                        t = i18n.tr("I'm listening to %1 via fLAs on my Ubuntu Phone! You can listen online here: %2").arg(curRadioName).arg(curRadioSource)
                    } else {
                        t = i18n.tr("Hi! I've found this cool online radio %1 via fLAs application on my Ubuntu Phone! Check this out yourself here: %2").arg(currentIndexModel.name).arg(radioStreamMODEL.model.get(0).streamUrl)
                    }
                    shareText(t)
                }
            }
        ]

    }
    
    onCurrentIndexModelChanged: {
        radioStreamMODEL.status = 0
        radioStreamMODELArray.status = 0

        if(mainRadioListView.currentIndex !== -1) {
            radioStreamMODEL.source = "http://www.rad.io/info/broadcast/getbroadcastembedded?broadcast=" + currentIndexModel.id
            radioStreamMODELArray.source = "http://www.rad.io/info/broadcast/getbroadcastembedded?broadcast=" + currentIndexModel.id
        }

    }


    // this will help reload image when user switch between top50,loacl,recomended stations.
    Connections {
        target: mainRadioListView
        onCountChanged: {
            if(mainRadioListView.currentIndex === 0) {
                var z = mainRadioListView.currentIndex
                mainRadioListView.currentIndex = -1
                mainRadioListView.currentIndex = z
            }
        }

    }

    Connections {
        target: mainAdaptivePageLayout
        onColumnsChanged: {
            testDelay.start()
        }

    }

    Timer {
        id: testDelay
        interval: 200
        onTriggered: {
            if(radioInfoSelections.selectedIndex == 0) {
                radioInfoSelections.selectedIndex = 1
                radioInfoSelections.selectedIndex = 0
            } else if(radioInfoSelections.selectedIndex == 1){
                radioInfoSelections.selectedIndex = 0
                radioInfoSelections.selectedIndex = 1
            } else if(radioInfoSelections.selectedIndex == 2){
                radioInfoSelections.selectedIndex = 1
                radioInfoSelections.selectedIndex = 2
            }
        }
    }
    
    // JSON model which holds radio details.
    JSONListModel {
        id: radioStreamMODELArray
        isArray: true
        query: "$"

        onStatusChanged: {
            if(status == 2) {
                print("Error loading data! Check you internet connection!")
            }
        }
    }

    // JSON model which holds mainly radio stream url.
    JSONListModel {
        id: radioStreamMODEL
        query: "$.streamUrls[*]"
    }


    JSONListModel {
        id: jsonFamilyStations
        query: "$[*]"
        //        source: "http://www.rad.io/info/index/searchembeddedbroadcast?q=" + jsonFamily.model.get(0).indexValue + "&start=0&rows=1000&streamcontentformats=aac,mp3"
    }


    ListView {
        id: mainRadioInfoListView

        anchors.fill: parent
        anchors.topMargin: root.header.height
        headerPositioning: ListView.PullBackHeader
        model: 1

        header: radioHeaderComponent
//        delegate: radioInfoDelegate
//        delegate: Rectangle {
//            width: parent.width
//            height: units.gu(40)
//            color: "blue"
//        }

        property int ooo

        Timer {
            id: listviewHeightDelay
            interval: 200
            onTriggered: {
                if(currentIndexSelected == 0) {
                    mainRadioInfoListView.ooo = tab1.height
                } else if (currentIndexSelected == 1) {
                    mainRadioInfoListView.ooo = tab2.height
                } else if (currentIndexSelected == 2) {
                    mainRadioInfoListView.ooo = tab3.height
                }

            }
        }

        delegate: componentTest2


    }


    Component {
        id: radioHeaderComponent
        // header ( radio main info + playbutton )
        Item {
            id: radioHeader
            width: parent.width
            height: units.gu(15)
            //            anchors.top: parent.top
            //            anchors.topMargin: root.header.height
            z: 2

            Image {
                id: bgImage
                anchors.fill: parent
                source: getImageSource(bgImage.status)
                fillMode: Image.PreserveAspectCrop

                Rectangle {
                    anchors.fill: bgImage
                    color: "black"
                    opacity: 0.6
                }
            }
            // image effect ( blur )
            //        RadialBlur {
            //            anchors.fill: bgImage
            //            source: bgImage
            //            samples: 24
            //            angle: 30
            //        }

            SlotsLayout {
                id: slotLayout
                height: radioHeader.height


                mainSlot: CrossFadeImage {
                    id: icon

                    height: slotLayout.height - units.gu(4)
                    width: height
                    fadeDuration: 400
                    source: bgImage.source
                }


                Item {
                    SlotsLayout.position: SlotsLayout.Trailing
                    height: slotLayout.height - units.gu(4)
                    width: slotLayout.width - slotLayout.height - units.gu(10)
                    opacity: radioStreamMODELArray.status == 0 ? 0 : 1

                    Behavior on opacity {
                        UbuntuNumberAnimation {}
                    }

                    Column {
                        width: parent.width
                        spacing: units.gu(1)
                        anchors.bottom: parent.bottom

                        Label {
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: "<b>"+i18n.tr("Genres ")+"</b>"+ radioStreamMODELArray.genres
                            color: "white"
                            visible: radioStreamMODELArray.genres !== ""
                        }
                        Label {
                            width: parent.width
                            color: "white"
                            wrapMode: Text.Wrap
                            text: ((radioStreamMODELArray.status == 1) && (radioStreamMODELArray.model.get(0).country !== "")) ?
                                      "<b>"+i18n.tr("From")+"</b>: " + radioStreamMODELArray.model.get(0).country + ", " +
                                      radioStreamMODELArray.model.get(0).city : ""
                        }
                        RatingIndicator {
                            ratingValue: radioStreamMODELArray.status == 1 ? radioStreamMODELArray.model.get(0).rating : 0
                        }
                    }
                }

                Item {
                    SlotsLayout.position: SlotsLayout.Trailing
//                    SlotsLayout.padding.top: units.gu(-2)
                    SlotsLayout.overrideVerticalPositioning: true
                    height: slotLayout.height - units.gu(4)
                    width: units.gu(6)
                    opacity: radioStreamMODELArray.status == 0 ? 0 : 1

                    Behavior on opacity {
                        UbuntuNumberAnimation {}
                    }
                    Icon {
                        name: ((mediaHub.playbackState == 1) && (currentIndexModel.id === curRadioId )) ? "media-playback-pause" : "media-playback-start"
                        width: playButtonMouseArea.pressed ? parent.width + units.gu(1) : parent.width - units.gu(1)
                        height: width
                        anchors.centerIn: parent
                        color: "white"
                        enabled: radioStreamMODEL.status == 1 ? true : false

                        Behavior on width {
                            UbuntuNumberAnimation {}
                        }

                        MouseArea {
                            id: playButtonMouseArea
                            anchors.fill: parent
                            anchors.margins: -units.gu(1)
                            onClicked: {
                                if(curRadioId === currentIndexModel.id) {
                                    mediaHub.playOrPause()

                                } else {
                                    curRadioName = root.header.title
                                    curRadioIcon = bgImage.source.toString()
                                    curRadioId = currentIndexModel.id
                                    curRadioSource = radioStreamMODEL.model.get(0).streamUrl
                                }
                                //                                if() {
                                //                                    mediaHub.playOrPause()
                                //                                }
                            }
                        }
                    }
                }


            }

            // previous radio
            UbuntuShape {
                id: leftNavigationButton

                width: units.gu(5)
                height: width
                clip: true
//                z: 20000
                color: theme.palette.normal.activity
                anchors {
//                    verticalCenter: radioHeader.bottom
//                    verticalCenterOffset: units.gu(3)
                    bottom: parent.bottom
                    bottomMargin: units.gu(0.5)
                }
//                opacity: 1

                Behavior on x { UbuntuNumberAnimation {} }

                states: [
                    State {
                        name: "hiden"
                        when: mainRadioListView.currentIndex === 0
                        PropertyChanges { target: leftNavigationButton; x: -units.gu(5) }
                    },
                    State {
                        name: "default"
                        when: mainRadioListView.currentIndex !== 0
                        PropertyChanges { target: leftNavigationButton; x: -units.gu(2) }
                    },
                    State {
                        name: "pressed"
                        PropertyChanges { target: leftNavigationButton; x: -units.gu(1) }
                    }

                ]

                Icon {
                    width: parent.width * 0.6
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    name: "go-previous"
                }

                MouseArea {
                    id: previousMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: leftNavigationButton.state === "hiden" ? false : true
//                    onEntered: parent.opacity = 0.8
//                    onExited: parent.opacity = 1
                    onPressed: leftNavigationButton.state = "pressed"
                    onReleased: leftNavigationButton.state = "default"
                    onClicked: mainRadioListView.currentIndex -= 1
                }
            }

            // next radio
            UbuntuShape {
                id: rightNavigationButton

                width: units.gu(5)
                height: width
                clip: true
//                color: UbuntuColors.coolGrey
                color: theme.palette.normal.activity

                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.gu(0.5)

//                    verticalCenter: radioHeader.bottom
//                    verticalCenterOffset: units.gu(3)

                }

                states: [
                    State {
                        name: "hiden"
                        when: mainRadioListView.currentIndex === curentListModel.count-1
                        PropertyChanges { target: rightNavigationButton; x: root.width + units.gu(1) }
                    },
                    State {
                        name: "default"
                        when: mainRadioListView.currentIndex !== curentListModel.count-1
                        PropertyChanges { target: rightNavigationButton; x: root.width - units.gu(3) }
                    },
                    State {
                        name: "pressed"
                        PropertyChanges { target: rightNavigationButton; x: root.width - units.gu(4) }
                    }

                ]

                Behavior on x { UbuntuNumberAnimation {} }
                Icon {
                    width: parent.width * 0.6
                    height: width
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    name: "go-next"
                }
                MouseArea {
                    id: nextRadioMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
//                    onEntered: parent.opacity = 0.8
//                    onExited: parent.opacity = 1
                    onPressed: rightNavigationButton.state = "pressed"
                    onReleased: rightNavigationButton.state = "default"
                    onClicked: mainRadioListView.currentIndex += 1
                    enabled: rightNavigationButton.state === " hiden" ? false : true
                }
            }


        }
    }



    Component {
        id: componentTest2
        Column {
            id: mainColumn
            width: mainRadioInfoListView.width

            states: [
                State {
                    name: "tab1"
                    PropertyChanges { target: mainRow; x: 0 }
                    PropertyChanges { target: mainColumn; height: rec1.height }
                    when: currentIndexSelected == 0
                },
                State {
                    name: "tab2"
                    PropertyChanges { target: mainRow; x: -mainRadioInfoListView.width }
                    PropertyChanges { target: mainColumn; height: rec2.height }
                    when: currentIndexSelected == 1
                },
                State {
                    name: "tab3"
                    PropertyChanges { target: mainRow; x: -mainRadioInfoListView.width * 2 }
                    PropertyChanges { target: mainColumn; height: rec3.height }
                    when: currentIndexSelected == 2
                }

            ]

            Item {
                width: parent.width
                height: mainRadioInfoListView.height - mainRadioInfoListView.headerItem.height
                visible: radioStreamMODELArray.status !== 1
                clip: true
                ActivityIndicator {
                    anchors.centerIn: parent
                    running: radioStreamMODELArray.status !== 1
                }
            }

            Row {
                id: mainRow
                clip: true

                Behavior on x {
                    UbuntuNumberAnimation {}
                }

                Tab1 {
                    id: rec1
                    width: mainRadioInfoListView.width
                }

                Tab2 {
                    id: rec2
                    width: mainRadioInfoListView.width
                }

                Rectangle {
                    id: rec3
                    width: mainRadioInfoListView.width
                    height: units.gu(80)
                    color: "green"
                }

            }

        }
    }







//    // previous radio
//    UbuntuShape {
//        id: leftNavigationButton

//        width: units.gu(5)
//        height: width
//        clip: true
//        z: 20000
//        color: UbuntuColors.coolGrey
//        anchors {
//            verticalCenter: radioHeader.bottom
//            verticalCenterOffset: units.gu(3)
//        }

//        Behavior on x { UbuntuNumberAnimation {} }

//        states: [
//            State {
//                name: "hiden"
//                when: mainRadioListView.currentIndex === 0
//                PropertyChanges { target: leftNavigationButton; x: -units.gu(5) }
//            },
//            State {
//                name: "default"
//                when: mainRadioListView.currentIndex !== 0
//                PropertyChanges { target: leftNavigationButton; x: -units.gu(2) }
//            },
//            State {
//                name: "pressed"
//                PropertyChanges { target: leftNavigationButton; x: -units.gu(1) }
//            }

//        ]

//        Icon {
//            width: parent.width * 0.6
//            height: width
//            anchors.right: parent.right
//            anchors.verticalCenter: parent.verticalCenter
//            color: "white"
//            name: "go-previous"
//        }

//        MouseArea {
//            id: previousMouseArea
//            anchors.fill: parent
//            hoverEnabled: true
//            enabled: leftNavigationButton.state === "hiden" ? false : true
//            onEntered: parent.opacity = 0.8
//            onExited: parent.opacity = 1
//            onPressed: leftNavigationButton.state = "pressed"
//            onReleased: leftNavigationButton.state = "default"
//            onClicked: mainRadioListView.currentIndex -= 1
//        }
//    }

//    // next radio
//    UbuntuShape {
//        id: rightNavigationButton

//        width: units.gu(5)
//        height: width
//        clip: true
//        color: UbuntuColors.coolGrey
//        anchors {
//            verticalCenter: radioHeader.bottom
//            verticalCenterOffset: units.gu(3)

//        }

//        states: [
//            State {
//                name: "hiden"
//                when: mainRadioListView.currentIndex === curentListModel.count-1
//                PropertyChanges { target: rightNavigationButton; x: root.width + units.gu(1) }
//            },
//            State {
//                name: "default"
//                when: mainRadioListView.currentIndex !== curentListModel.count-1
//                PropertyChanges { target: rightNavigationButton; x: root.width - units.gu(3) }
//            },
//            State {
//                name: "pressed"
//                PropertyChanges { target: rightNavigationButton; x: root.width - units.gu(4) }
//            }

//        ]

//        Behavior on x { UbuntuNumberAnimation {} }
//        Icon {
//            width: parent.width * 0.6
//            height: width
//            anchors.left: parent.left
//            anchors.verticalCenter: parent.verticalCenter
//            color: "white"
//            name: "go-next"
//        }
//        MouseArea {
//            id: nextRadioMouseArea
//            anchors.fill: parent
//            hoverEnabled: true
//            onEntered: parent.opacity = 0.8
//            onExited: parent.opacity = 1
//            onPressed: rightNavigationButton.state = "pressed"
//            onReleased: rightNavigationButton.state = "default"
//            onClicked: mainRadioListView.currentIndex += 1
//            enabled: rightNavigationButton.state === " hiden" ? false : true
//        }
//    }



}
