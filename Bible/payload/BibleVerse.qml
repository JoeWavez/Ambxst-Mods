import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: verseWidget
    
    Layout.fillWidth: true
    implicitHeight: 160
    
    color: "#1e1e2e" 
    radius: 12
    border.color: "#313244"
    border.width: 1

    property var allVerses: []
    property int currentIndex: 0
    property string verseText: "Loading verse..."
    property string verseRef: ""
    property string verseCategory: ""

    Component.onCompleted: {
        loadVerses();
    }

    function loadVerses() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", Qt.resolvedUrl("verses.json"));
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) {
                    try {
                        allVerses = JSON.parse(xhr.responseText).verses || JSON.parse(xhr.responseText);
                        if (allVerses.length > 0) {
                            var now = new Date();
                            var start = new Date(now.getFullYear(), 0, 0);
                            var diff = (now - start) + ((start.getTimezoneOffset() - now.getTimezoneOffset()) * 60 * 1000);
                            var dayOfYear = Math.floor(diff / (1000 * 60 * 60 * 24));
                            
                            currentIndex = dayOfYear % allVerses.length;
                            displayVerse(currentIndex);
                        }
                    } catch (e) {
                        verseText = "Error parsing JSON data.";
                    }
                } else {
                    verseText = "Failed to load verses file.";
                }
            }
        }
        xhr.send();
    }

    function displayVerse(index) {
        var item = allVerses[index];
        verseText = item.text;
        verseRef = item.reference;
        verseCategory = item.category;
    }

    function nextVerse() {
        if (allVerses.length > 0) {
            currentIndex = (currentIndex + 1) % allVerses.length;
            displayVerse(currentIndex);
        }
    }

    function prevVerse() {
        if (allVerses.length > 0) {
            currentIndex = (currentIndex - 1 + allVerses.length) % allVerses.length;
            displayVerse(currentIndex);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                implicitWidth: catText.implicitWidth + 14
                implicitHeight: 20
                radius: 10
                color: "#313244"

                Text {
                    id: catText
                    text: verseCategory.toUpperCase()
                    font.pixelSize: 9
                    font.bold: true
                    color: "#cba6f7"
                    anchors.centerIn: parent
                }
            }

            Text {
                text: verseRef
                font.pixelSize: 12
                font.bold: true
                color: "#89b4fa"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Rectangle {
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: prevMouse.containsMouse ? "#45475a" : "transparent"

                Text {
                    text: "‹"
                    color: "#a6adc8"
                    font.pixelSize: 14
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: prevVerse()
                }
            }

            Rectangle {
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: nextMouse.containsMouse ? "#45475a" : "transparent"

                Text {
                    text: "›"
                    color: "#a6adc8"
                    font.pixelSize: 14
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: nextVerse()
                }
            }
        }

        Text {
            text: '"' + verseText + '"'
            font.pixelSize: 12
            font.italic: true
            color: "#cdd6f4"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 4
            elide: Text.ElideRight
        }
    }
}
