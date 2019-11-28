import QtQuick 2.4
import Ubuntu.Components 1.3

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


    Component {
        id: mainPageDelegate
        MainListItemDelegate {
            id: radioJSONListModel
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
            mainRadioListView.currentIndex = -1
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
                    mainPage.header = searchHeader
                }
            }
//                    ,Action {
//                        iconName: "help"
//                        text: "lol"
//                        onTriggered: mainAdaptivePageLayout.addPageToNextColumn(mainPage, Qt.resolvedUrl("RadioMainPagePreview.qml"))
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
                if(text.length === 0) {
                    searchDelay.stop()
                    searchListModel.source = ""
//                            isLoaded = true
                } else {
                    searchDelay.start()
                }
            }

            Timer {
                id: searchDelay
                interval: 800
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

    ActivityIndicator {
        anchors.centerIn: parent
//                running: (!mainRadioListView.visible && mainPage.header === standardHeader)
        running: !mainRadioListView.visible
    }

    UbuntuListView {
        id: mainRadioListView

        clip: true
        width: parent.width
        anchors.top: parent.header.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: mainView.height - mediaPlayerBottomEdge.y
        model: mainPage.header === standardHeader ? jsonModel.model : searchListModel.model
        visible: (jsonModel.status == 1) || (searchListModel.status == 1) ? true : false
        cacheBuffer: contentItem.height * 10
//                cacheBuffer: contentHeight === -1 ? 0 : contentHeight
        flickDeceleration: 3000
        maximumFlickVelocity: 15000
        delegate: mainPageDelegate

        pullToRefresh {
            enabled: mainPage.header === standardHeader ? true : false
            refreshing: jsonModel.status != 1 ? true : false
            onRefresh: jsonModel.reload()
        }
    }

    // animated text when user search for station.
    AnimatedLabel {
        fontSize: "large"
        newText: searchTextField.text.length === 0 ? i18n.tr("Type station name.") : jsonModel.status === 0 ? i18n.tr("Searching...") : i18n.tr("No results found :-(")
        anchors.centerIn: parent
        anchors.bottomMargin: units.gu(8)
        width: parent.width
        horizontalAlignment: Text.Center
        wrapMode: Text.Wrap
        visible: ((mainPage.header === searchHeader) && (searchListModel.model.count === 0)) ? true : false
    }

    Column {
        width: parent.width
        anchors.centerIn: parent
        spacing: units.gu(1)
        visible: (jsonModel.status === 2 && mainPage.header === standardHeader) ? true : false

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
            onClicked: jsonModel.reloadListModel()
        }
    }


    // Scrollbar
    Scrollbar{
        flickableItem: mainRadioListView
        align: Qt.AlignTrailing
//                visible: isLoaded
    }


}
