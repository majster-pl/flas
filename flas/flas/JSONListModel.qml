/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 * modified by Szymon Waliczek <majsterrr@gmail.com>
 */

import QtQuick 2.4
import com.canonical.Oxide 1.9
import Ubuntu.Connectivity 1.0
import Ubuntu.Components.Popups 1.3


import "jsonpath.js" as JSONPath
import "base64.js" as BASE64

FocusScope {
    id: root
    visible: false
    property string source: ""
    property string query: ""
    property int status: 3 // 0 = Loading, 1 = ready , 2 = Error, 3 = NoStatus, 4 = CheckingInternet
    property string jsonString: ""
    property bool isArray: false
    property string usContext: "messaging://"
    property ListModel model : ListModel { }

    property ListModel recentTitles: ListModel {}
    property string family: ""
    property string language: ""
    property string topics: ""
    property string genres: ""

    property bool openDialog: false

    onOpenDialogChanged: {
        if(openDialog) {
            PopupUtils.open(noInternetPopOver)
        } else {
            PopupUtils.close(noInternetPopOver)
        }
    }


    function resetArrayData() {
        recentTitles.clear()
        family = ""
        language = ""
        topics = ""
        genres = ""
    }

//    onStatusChanged: {
//        print("----------------------------------")
//        print("status is: ", status)
//        print("----------------------------------")
//    }

    Connections {
        target: Connectivity
        // full status can be retrieved from the base C++ class
        // status property
//        onStatusChanged: console.log("Status: " + statusMap[Connectivity.status])
        onOnlineChanged: {
            if(Connectivity.online) {
                reload()
                mediaHub.playOrPause()
            } else {
                isLoaded = false
                root.status = 2
                mediaHub.stop()
            }

            console.log("Online: " + Connectivity.online)
        }
    }
    
    function reload() {
//        isLoaded = false
        root.status = 0
        var a = source
        root.source = ""
        root.source = a
    }

    function loadDelay() {
        loadListDelay.start()
    }

    function parseJSON(json, query) {
        var jsonData
        try{
            jsonData = JSON.parse(json, query);
            if(query !== "") jsonData = JSONPath.jsonPath(jsonData, query)
//            if(jsonData.lenght === undefined) isLoaded = true
//            root.status = 0
            console.log("[LOG]","JSON parsing: OK")
            return jsonData
        }catch(e){
            root.status = 2
            console.error("[ERROR]", "parsing JSON")
        }
    }

    function loadList() {
        model.clear();
//        isLoaded = false
        var objectArray = parseJSON(jsonString, query);
        if(!isArray) {
            for ( var key in objectArray ) {
                var jo = objectArray[key];
    //            print(jo[0])
                model.append( jo );
                root.status = 1
            }
        } else {
            resetArrayData()
            try {
                for(var key2 in objectArray[0]) {
                    var jo2 = objectArray[0]

                    for (var key3 in jo2) {
//                        print(key3)
                        try {
                            if(key3 === "family") {
                                family = jo2.family[0]
                            } else if(key3 === "recentTitles") {
                                for (var r1 in key3) {
//                                    print(String(jo2.recentTitles[r1]))
                                    if(typeof jo2.recentTitles[r1] != "undefined") {
                                        recentTitles.append({"trackName": jo2.recentTitles[r1]})
                                    }

//                                    recentTitles.push([jo2.recentTitles[r1]])
                                }

                            }
                            else if(key3 === "language") {
                                language = jo2.language[0]
                            }
                            else if (key3 === "topics") {
                                topics = jo2.topics[0]
                            }
                            else if(key3 === "genres") {
                                genres = jo2.genres[0]
                            }

                        }
                        catch(err) {
                            console.log(err)
                        }


                    }

                    model.append(jo2)
                    root.status = 1
//                    print(jo2.family)
                    break
                }
            }
            catch(err) {
                root.status = 2
                console.log("[ERROR] Loading Error!")
            }


        }

    }

//    Timer {
//        id: internetChecker
//        interval: 5000
//        running: root.status == 2
//        repeat: true
//        onTriggered: {
//            print("Checking connection....")
//            reload()
//        }
//    }

    Timer {
        id: loadListDelay
        interval: 200
        repeat: false
        onTriggered: loadList()
    }

//    onModelChanged: reloadListModel()
//    onSourceChanged: reloadListModel()
//    onQueryChanged: loadList()
    onQueryChanged: {
//        print("QUERY CHANGED TO:",query)
        if(root.status != 3) {
            isLoaded = false
            loadListDelay.start()
//            loadList()
        }
    }


    WebContext {
        id: webcontext
        userAgent: "XBMC Addon Radio"
        userScripts: [
            UserScript {
                context: usContext
                url: Qt.resolvedUrl("oxide_user.js")
            }
        ]
    }

    WebView {
        id: webview
        anchors {
            fill: parent
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        context: webcontext
        url: source
//        url: "https://dl.dropboxusercontent.com/u/4467345/test.hmlt"

        function getHTML(callback) {
//            print("getHTML function!")
            var req = webview.rootFrame.sendMessage(usContext, "GET_HTML", {})
            req.onreply = function (msg) {
                callback(msg.html);
//                root.status = 0
            }
            req.onerror = function (code, explanation) {
                root.status = 2
                console.log("Error " + code + ": " + explanation)
            }
        }

        onLoadProgressChanged: {
            if(loadProgress === 100) {
                print("LETS LOAD!")
                webview.getHTML(function callback(code){
                    jsonString = code.slice(code.search(';">')+3)
                    jsonString = jsonString.slice(0, jsonString.search('</pre'))
//                    print('Downloaded content:',jsonString)
//                    webview.stop()
                    if(root.status != 2) {
//                        print("LETS LOAD!")
                        loadList()
                    }
                })
            }
        }



    }

//    Component.onCompleted: reload()


}
