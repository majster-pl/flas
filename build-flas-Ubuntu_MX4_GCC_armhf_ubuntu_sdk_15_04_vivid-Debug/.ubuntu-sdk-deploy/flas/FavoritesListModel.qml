/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 * modified by Szymon Waliczek <majsterrr@gmail.com>
 */

import QtQuick 2.4

import "jsonpath.js" as JSONPath
import "base64.js" as BASE64

ListModel {
    id: listModel
    property var main_list: []
    property int count: main_list.length

//    onCountChanged: print("KUIPA:", count)

    //load favorites on start
    Component.onCompleted: load()

    onMain_listChanged: {

    }

    //Loading main_list
    function load() {
        if (favoritesDB.contents.favoritesList) {
            main_list = JSON.parse(favoritesDB.contents.favoritesList)
            loadMainList()
//            main_shopping_list_MODEL.append(main_list)
            console.log('[LOG]: Favorites list loaded.')
        } else {
            console.log('[LOG]: Favorites list is empty.')
        }
    }


    // Adding new List to mainShopListModel
    function add(radio_id, radio_name, icon_source, stream_url) {
        var o = {"radioId": radio_id, "radioName": radio_name, "iconUrl": icon_source, "streamUrl": stream_url}
        main_list.unshift(o)
        listModel.insert(0, o)
        saveMainList()
    }


    // remove radio from favorites
    function removeRadio(radio_id) {
        for(var i=0; i<main_list.length; i++) {
//            print("BUUU", main_list[i].radioId)
            if(main_list[i].radioId === radio_id) {
                print(main_list[i].radioName)
                main_list.splice(i, 1)
                listModel.remove(i)
            }

        }
        saveMainList()
    }


    // return true if radioId in favorite list
    function isFavorite(radio_id) {
        for(var i=0; i<main_list.length; i++) {
            if(main_list[i].radioId === radio_id) return true
        }

    }



    // load main_list to main_shopping_list_MODEL
    function loadMainList() {
        main_list = JSON.parse(favoritesDB.contents.favoritesList)
        listModel.append(main_list)
    }


    ///// SAVING LIST
    function saveMainList() {
//        listModel.clear()
        var tempMainList = {}
        tempMainList = favoritesDB.contents
        tempMainList.favoritesList = JSON.stringify(main_list)
        print("++++++++++++++++++++++++")
        print(tempMainList.favoritesList)
        print("++++++++++++++++++++++++")
        favoritesDB.contents = tempMainList
        main_list = JSON.parse(favoritesDB.contents.favoritesList)
//        loadMainList()
    }



}
