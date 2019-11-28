import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import U1db 1.0 as U1db
import Qt.labs.settings 1.0
//import "Components"

MainView {
    id: mainView

    applicationName: "flas.majster-pl"
    anchorToKeyboard: true
    width: units.gu(50)
    height: units.gu(75)

    theme.name: "Ubuntu.Components.Themes.SuruDark"

    property bool isLoaded: false

//    onIsLoadedChanged: {
//        print("ooooooooooooooooooooooooooooooooooooo")
//        print("is loaded: ", isLoaded)
//        print("ooooooooooooooooooooooooooooooooooooo")
//    }

//    property string pathToShare: "/home/phablet/.local/share/flas.majster-pl/cache/images/"
    property string pathToShare: "/home/szymon/.local/share/flas.majster-pl/cache/images/"


    // current radio metaData
    property string curRadioName
    property string curRadioIcon
    property string curRadioSource: ""
    property int curRadioId

    property bool loadingStream: false
    property bool isStopped: false
    property string tempCurRadioSource

//    onCurRadioNameChanged: print("Radio name:",curRadioName)
//    onCurRadioSourceChanged: print("Radio source:",curRadioSource)
    onCurRadioSourceChanged: {
        loadingStream = true
        loadSource.start()
    }

    property var testArray

    onTestArrayChanged: {
        print("TESTarray jest now:",testArray.length)
        for (var i in testArray) {
            print(testArray[i])
        }
    }

    onIsStoppedChanged: {
        if(isStopped) {
            mediaHub.source = ""
        } else {
            loadingStream = true
            var t = curRadioSource
            curRadioSource = ""
            curRadioSource = t
        }
    }

//    onCurRadioSourceChanged: print("source:",curRadioSource)


    // Sharing functions:
    function instantiateShareComponent() {
        var component = Qt.createComponent("Share.qml")
        if (component.status == Component.Ready) {
            var share = component.createObject(mainView)
            share.onDone.connect(share.destroy)
            return share
        }
        return null
    }

    function shareLink(url, title) {
        var share = instantiateShareComponent()
        if (share) share.shareLink(url, title)
    }

    function shareText(text) {
        var share = instantiateShareComponent()
        if (share) share.shareText(text)
    }

    Settings {
        id: settings
        property bool top50Tip: true
        property bool localTip: true
        property bool recomendedTip: true

//        function add() { count += 1 }

    }


    // Definig U1 database
    U1db.Database {
        id: storage
        path: "cache/images/favorites.u1db"
    }

    // doc to store favorite stations
    U1db.Document {
        id: favoritesDB
        database: storage
        docId: 'favorites'
        create: true
        defaults: {
            favoritesList: []
        }
    }

    // doc to store last played Station
    U1db.Document {
        id: lastRadioDB
        database: storage
        docId: 'lastRadio'
        create: true
        defaults: { "lastRadioArray": "true" }

        function save(radio_name, radio_icon, radio_url, radio_id) {
            lastRadioDB.contents = { "lastRadioArray": [radio_name, radio_icon, radio_url, radio_id] }
        }

        function read() {
            if(String(lastRadioDB.contents.lastRadioArray) !== "true") {
                curRadioName = lastRadioDB.contents.lastRadioArray[0]
                curRadioIcon = lastRadioDB.contents.lastRadioArray[1]
//                curRadioSource = lastRadioDB.contents.lastRadioArray[2]
                tempCurRadioSource = lastRadioDB.contents.lastRadioArray[2]
                curRadioId = lastRadioDB.contents.lastRadioArray[3]
                loadingStream = false
            }
        }

        function read2(){
            print(String(lastRadioDB.contents.lastRadioArray))
        }

        Component.onCompleted: read()
    }


    FavoritesListModel {
        id: favoritesListModel
    }

//    Connections {
//        target: Qt.inputMethod
//        onVisibleChanged: console.log("OSK visible: " + visible)
//    }

    JSONListModel {
        id: jsonModel
        Component.onCompleted: {
//            query = "$.topBroadcasts[*]"
            source = "http://www.rad.io/info/account/getmostwantedbroadcastlists?sizeoflists=50"
//            source = "http://www.rad.io/info/index/searchembeddedbroadcast?q=" + "BBC" + "&start=0&rows=1000&streamcontentformats=aac,mp3"
        }

        onStatusChanged: {
            if(status == 2) {
                mainPage.header.enabled = false
            } else {
                mainPage.header.enabled = true
            }
        }
    }

    // search ListModel
    JSONListModel {
        id: searchListModel
    }


    Component {
        id: mainPageDelegate
        MainListItemDelegate {z:1}
    }



    AdaptivePageLayout {
        id: mainAdaptivePageLayout
        anchors.fill: parent
        primaryPage: mainPage

        onColumnsChanged: {
            if(mainAdaptivePageLayout.columns === 2) {
                if(mainRadioListView.currentIndex === -1) {
//                    mainRadioListView.currentIndex = 0
//                    mainAdaptivePageLayout.addPageToNextColumn(mainPage, favoritesPage)
                    mainAdaptivePageLayout.addPageToNextColumn(mainPage, favoritesPage)
                } else if (mainRadioListView.currentIndex >= 0) {
//                    mainRadioListView.currentIndex = 0
                    mainAdaptivePageLayout.addPageToNextColumn(mainPage, radioMainPage)
                }


            }
        }

        Component.onCompleted: {
            if(mainAdaptivePageLayout.columns === 2) {
                if(mainRadioListView.currentIndex === -1) {
//                    mainRadioListView.currentIndex = 0
//                    mainAdaptivePageLayout.addPageToNextColumn(mainPage, favoritesPage)
                    mainAdaptivePageLayout.addPageToNextColumn(mainPage, favoritesPage)
                } else if (mainRadioListView.currentIndex >= 0) {
//                    mainRadioListView.currentIndex = 0
                    mainAdaptivePageLayout.addPageToNextColumn(mainPage, radioMainPage)
                }


            }

        }

        Page {
            id: mainPage
            // to control head selections.
            Connections {
                target: mainPage.header.sections
                onSelectedIndexChanged: {
//                    mainRadioListView.currentIndex = -1
                    // NOTE: be careful on changing the way filters are assigned, if we create a
                    // binding on head.sections, we might get weird results when the page moves to the bottom
                    if (mainPage.header.sections.selectedIndex === 0) {
//                        print("ooooooooooooofa bdj fn o")
//                        mainRadioListView.currentIndex = 0
                        jsonModel.source = "http://www.rad.io/info/account/getmostwantedbroadcastlists?sizeoflists=50"
                        jsonModel.query = "$.topBroadcasts[*]"
                    } else if (mainPage.header.sections.selectedIndex === 1){
//                        mainRadioListView.currentIndex = 0
                        jsonModel.source = "http://www.rad.io/info/account/getmostwantedbroadcastlists?sizeoflists=50"
                        jsonModel.query = "$.localBroadcasts[*]"
                    } else if (mainPage.header.sections.selectedIndex === 2) {
//                        mainRadioListView.currentIndex = 0
                        jsonModel.source = "http://www.rad.io/info/account/getmostwantedbroadcastlists?sizeoflists=50"
                        jsonModel.query = "$.recommendedBroadcasts[*]"
                    }
                }
            }

            header: standardHeader
            onHeaderChanged: {
                if(header === searchHeader) {
                    searchTextField.forceActiveFocus()
                    if(searchTextField.text.length === 0) {
                        searchDelay.stop()
//                        jsonModel.source = ""
//                        jsonModel.model.clear()
//                        isLoaded = true
                    } else {
                        searchDelay.start()
                    }
                } else {
//                    isLoaded = false
//                    mainRadioListView.currentIndex = -1
                    // NOTE: be careful on changing the way filters are assigned, if we create a
                    // binding on head.sections, we might get weird results when the page moves to the bottom
                    if (mainPage.header.sections.selectedIndex === 0) {
                        jsonModel.source = "http://www.rad.io/info/account/getmostwantedbroadcastlists?sizeoflists=50"
                        jsonModel.query = "$.topBroadcasts[*]"
                    } else if (mainPage.header.sections.selectedIndex === 1){
                        jsonModel.source = "http://www.rad.io/info/account/getmostwantedbroadcastlists?sizeoflists=50"
                        jsonModel.query = "$.localBroadcasts[*]"
                    } else if (mainPage.header.sections.selectedIndex === 2) {
                        jsonModel.source = "http://www.rad.io/info/account/getmostwantedbroadcastlists?sizeoflists=50"
                        jsonModel.query = "$.recommendedBroadcasts[*]"
                    }

                }
            }

            PageHeader {
                id: standardHeader
                title: "flas"
                sections.model: [i18n.tr("Top 50"), i18n.tr("Local"), i18n.tr("Recommended")]
//                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                visible: mainPage.header === standardHeader
                trailingActionBar.actions: [
                    Action {
                        iconName: "non-starred"
                        text: "Favorites"
                        onTriggered: mainAdaptivePageLayout.addPageToNextColumn(mainPage, favoritesPage)
                    },
                    Action {
                        iconName: "search"
                        text: "Third"
                        onTriggered: {
//                            isLoaded = true
                            mainPage.header = searchHeader
                        }
                    }
//                    ,
//                    Action {
//                        iconName: "help"
//                        text: "Third"
//                        onTriggered: {
//                            jsonModel.reload()
//                        }
//                    }

                ]
            }


            PageHeader {
                id: searchHeader
                visible: mainPage.header === searchHeader
                leadingActionBar.actions: [
                    Action {
                        iconName: "back"
                        text: "Back"
                        onTriggered: mainPage.header = standardHeader
                    }
                ]

                contents: TextField {
                    id: searchTextField
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    inputMethodHints: Qt.ImhNoPredictiveText
                    placeholderText: "Search..."
                    onTextChanged: {
                        isLoaded = false
                        if(text.length === 0) {
                            searchDelay.stop()
                            searchListModel.model.clear()
                            isLoaded = true
                        } else {
                            searchDelay.start()
                        }
                    }

                    Timer {
                        id: searchDelay
                        interval: 1000
                        running: false
                        onTriggered: {
//                            isLoaded = false
                            searchListModel.source = "http://www.rad.io/info/index/searchembeddedbroadcast?q=" + parent.text
                                    + "&start=0&rows=50&&streamcontentformats=aac,mp3"
                            searchListModel.query = "$[*]"
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: units.gu(2)
                anchors.centerIn: parent
//                visible: (!mainRadioListView.visible && (jsonModel.status != 2))

                Label {
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: mainPage.header === standardHeader ? i18n.tr("Loading radio list...") : i18n.tr("Searching...")
                    horizontalAlignment: Text.AlignHCenter
                    visible: (!mainRadioListView.visible && (jsonModel.status != 2))
                }

                Label {
                    width: parent.width
                    wrapMode: Text.Wrap
                    fontSize: "large"
                    text: i18n.tr("No radio found :(")
                    visible: (mainRadioListView.model.count === 0 && searchTextField.text.length !== 0 && isLoaded)
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    width: parent.width
                    wrapMode: Text.Wrap
                    fontSize: "large"
                    text: i18n.tr("Type radio name")
                    visible: (mainRadioListView.model.count === 0 && searchTextField.text.length === 0 && isLoaded)
                    horizontalAlignment: Text.AlignHCenter
                }

                ActivityIndicator {
    //                running: (!mainRadioListView.visible && mainPage.header === standardHeader)
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: (!mainRadioListView.visible && (jsonModel.status != 2)) ? true : false
                    visible: (!mainRadioListView.visible && (jsonModel.status != 2))
                }
            }



            UbuntuListView {
                id: mainRadioListView

                clip: true
                width: parent.width
                anchors.top: parent.header.bottom
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Qt.inputMethod.visible ? 0 : mediaPlayerBottomEdge.playerHeight
                model: mainPage.header === standardHeader ? jsonModel.model : searchListModel.model
//                visible: (jsonModel.status == 1) || (searchListModel.status == 1) ? true : false
                visible: isLoaded
                cacheBuffer: contentHeight
//                cacheBuffer: contentHeight === -1 ? 0 : contentHeight
                flickDeceleration: 3000
                maximumFlickVelocity: 15000
                delegate: mainPageDelegate
                headerPositioning: ListView.OverlayHeader


                header: HeaderDelegate {z:3}

                pullToRefresh {
                    enabled: mainPage.header === standardHeader ? true : false
                    refreshing: jsonModel.status == 0 ? true : false
                    onRefresh: jsonModel.reload()
                    z: mainRadioListView.headerItem.z - 10
                }
            }

//            // animated text when user search for station.
//            AnimatedLabel {
//                fontSize: "large"
//                newText: searchTextField.text.length === 0 ? i18n.tr("Type station name.") : jsonModel.status === 1 ? i18n.tr("No results found :-(") : i18n.tr("Searching...")
//                anchors.centerIn: parent
//                anchors.bottomMargin: units.gu(8)
//                width: parent.width
//                horizontalAlignment: Text.Center
//                wrapMode: Text.Wrap
//                visible: ((mainPage.header === searchHeader) && (searchListModel.model.count === 0)) ? true : false
//            }

            Column {
                width: parent.width
                anchors.centerIn: parent
                spacing: units.gu(1)
//                visible: (jsonModel.status === 2 && mainPage.header === standardHeader) ? true : false
                visible: (jsonModel.status == 2) || (searchListModel.status == 2) ? true : false
//                visible: mainRadioListView.model === jsonModel.model ? (jsonModel.status == 2 ? true : false) :
//                                                                       (searchListModel.status == 2 ? true : false)

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.Center
                    text: i18n.tr("No interent connection\nPlease check you internet connection.")
                    visible: parent.visible
                }

                Button {
                    text: "Reload"
                    visible: parent.visible
//                    anchors.centerIn: parent
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: jsonModel.reload()
                }
            }


            // Scrollbar
            Scrollbar{
                flickableItem: mainRadioListView
                align: Qt.AlignTrailing
                visible: isLoaded
            }


        }
        RadioMainPage {
            id: radioMainPage
            visible: false
            anchors.fill: parent
            anchors.bottomMargin: mainAdaptivePageLayout.columns === 2 ? 0 : mediaPlayerBottomEdge.playerHeight
//            anchors.fill: parent
        }

//        FavoritesPage {
//            id: favoritesPage
//            visible: false
//        }

        Page {
            id: page3
            visible: false
    //        title: ""
            SequentialAnimation {
                id: seqAnimation
                NumberAnimation { target: chooseRadioLabel; property: "opacity"; to: 1; duration: 700 }
                PauseAnimation { duration: 1000 }
                NumberAnimation { target: chooseRadioLabel; property: "opacity"; to: 0; duration: 400 }
            }

            Column {
    //            width: parent.width
                anchors.centerIn: parent
                spacing: units.gu(3)

                Label {
                    id: chooseRadioLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0
                    text: "Choose radio on the left!"
                    fontSize: "x-large"
                }

                Icon {
                    name: "media-playback-start"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: units.gu(14)
                }
            }
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    seqAnimation.start()
                }
            }
        }

        // Favorites
        FavoritesPage {
            id: favoritesPage
            visible: false
        }

    }

    Timer {
        id: loadSource
        interval: 500
        running: false
        repeat: false
        onTriggered: mediaHub.source = curRadioSource
    }

    Timer {
        id: playDelay
        interval: 200
        running: false
        repeat: false
        onTriggered: mediaHub.play()
    }



    MediaPlayerBottomEdge {
        id: mediaPlayerBottomEdge
        width: mainAdaptivePageLayout.columns === 1 ? parent.width : mainPage.width
        onYChanged: {
            playerHeight = mainView.height - y
//            print("o taki jest Y:" ,y)
        }

        barState: jsonModel.status == 1 ? "open" : "hiden"
    }


    MediaPlayer {
        id: mediaHub
        autoPlay: curRadioSource === "" ? false : true

//        source: curRadioSource

        onSourceChanged: print("current Radio source is:",source)

        onPlaybackStateChanged: {
            print("NOW STATE IS:",playbackState)
            if(playbackState === MediaPlayer.PlayingState) {
                loadingStream = false
                lastRadioDB.save(curRadioName, curRadioIcon, curRadioSource, curRadioId)
//                isStopped = false
            }
        }

        function playOrPause() {
            if(curRadioSource === "") {
                curRadioSource = tempCurRadioSource
                return
            }

//            if(isStopped) {
//                isStopped = false
//                mediaHub.play()
//                return
//            }


            if(playbackState === MediaPlayer.PlayingState) {
//                isStopped = true
                mediaHub.stop()
            } else if (playbackState === MediaPlayer.StoppedState) {
                loadingStream = true
                playDelay.start()
//                mediaHub.play()
            }
        }

//        onPlaying: {
//            print("Paly pressed!")
//            if(mediaHub.source == "") { mediaHub.source = curRadioSource }
//        }

//        onStopped: {
//            print("STOP pressed!")
//            mediaHub.source = ""
//        }

        onStatusChanged: {
            print("Playing STATUS:", status)
//            print("---------------------------------------")
//            UnknownStatus 0
//            NoMedia 1
//            Loading 2
//            Loaded 3
//            Stalled 4
//            Buffering 5
//            Buffered 6
//            EndOfMedia 7
//            InvalidMedia 8
//            print("---------------------------------------")
            if(status === MediaPlayer.Loaded) {
                loadingStream = false
//                mediaPlayerBottomEdge.openBottomEdge()
            } else if (status === MediaPlayer.Buffered) {
                loadingStream = false
            } else if (status === MediaPlayer.Stalled) {
                loadingStream = true
            } else if (status === MediaPlayer.InvalidMedia) {
                curRadioSource = ""
                print("*****************************")
                print("LOOO JA JEVBIE!!! :DD:")
                print("*****************************")
            }
        }

    }



}

