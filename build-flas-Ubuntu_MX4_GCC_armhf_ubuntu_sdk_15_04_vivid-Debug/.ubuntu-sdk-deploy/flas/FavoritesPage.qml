import QtQuick 2.4
import Ubuntu.Components 1.3
//import "components"

Page {
    id: favoritesPage
    header: PageHeader {
        title: i18n.tr("Favorites")
        flickable: null
    }

    Flickable {
        anchors.fill: parent
        anchors.topMargin: parent.header.height + units.gu(3)
        anchors.bottomMargin: mediaPlayerBottomEdge.playerHeight + units.gu(2)
        contentHeight: lol.height
        contentWidth: parent.width
        Column {
    //        anchors.centerIn: parent
            id: lol
            width: parent.width - units.gu(4)
            anchors.horizontalCenter: parent.horizontalCenter
            visible: favoritesListModel.count > 0 ? false : true
            spacing: units.gu(1)


            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                fontSize: "x-large"
                text: "No favorites saved yet\n\n"
            }
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                fontSize: "large"
                text: "Find radio in the main list then swipe it left and click on ★"
            }

            Image {
                width: parent.width
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl("hint1.png")
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                fontSize: "x-large"
                text: "or"
            }



            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                fontSize: "large"
                text: "Click on radio station and then press ★ symbol in the top right corner."
            }

            Image {
                width: parent.width
                fillMode: Image.PreserveAspectFit
                source: Qt.resolvedUrl("hint2.png")
            }


        }
    }



    ListView {
        id: favoritesListView
        anchors {fill: parent; topMargin: parent.header.height}
        model: favoritesListModel
        visible: favoritesListModel.count > 0 ? true : false
        delegate: favoriteComponent
        add: Transition {
            NumberAnimation { properties: "y"; duration: 500 }
        }
        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 500 }
        }
    }

    Component {
        id: favoriteComponent
        FavoriteListItemDelegate {}
    }

}
