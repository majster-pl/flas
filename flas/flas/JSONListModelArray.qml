/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 * modified by Szymon Waliczek <majsterrr@gmail.com>
 */

import QtQuick 2.4
import com.canonical.Oxide 1.9

import "jsonpath.js" as JSONPath
import "base64.js" as BASE64

FocusScope {
    id: root
    visible: false
    property string source: ""
    property string query: ""
    property int status // 0 = Loading, 1 = ready , 2 = Error
    property string jsonString: ""
    property string usContext: "messaging://"
    property ListModel model : ListModel { id: jsonModel }

    function reloadListModel() {
        var a = source
        source = ""
        source = a
    }

    function parseJSON(json, query) {
        var jsonData
        try{
            jsonData = JSON.parse(json, query);
            if(query !== "") jsonData = JSONPath.jsonPath(jsonData, query)
            root.status = 0
            console.log("[LOG]","JSON parsing: OK")
            return jsonData
        }catch(e){
            root.status = 2
            console.error("[ERROR]", "parsing JSON")
        }
    }

    function loadList() {
        model.clear();
        var objectArray = parseJSON(jsonString, query);
        for(var key in objectArray[0]) {
            var jo = objectArray[0]
            jsonModel.append(jo)
        }
        root.status = 1
    }


    function reload() {
        var temp = source
        source = ""
        source = temp
    }

    Binding {
        target: webview
        property: "loading"
        value: webview.loading ? root.status = 1 : root.status = 0
    }

    onQueryChanged: loadList()

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

        function getHTML(callback) {
            var req = webview.rootFrame.sendMessage(usContext, "GET_HTML", {})
            req.onreply = function (msg) {
                callback(msg.html);
            }
            req.onerror = function (code, explanation) {
                console.log("Error " + code + ": " + explanation)
            }
        }

        onLoadProgressChanged: {
            if(loadProgress === 100) {
                webview.getHTML(function callback(code){
                    jsonString = code.slice(code.search(';">')+3)
                    jsonString = jsonString.slice(0, jsonString.search('</pre'))
//                    print('KURWA MAC!',jsonString)
                    loadList()
                })
            }
        }



    }


}

