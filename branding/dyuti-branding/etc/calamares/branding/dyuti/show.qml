/*
 * Dyuti OS installer slideshow (Calamares Slideshow API 2).
 * Plays while the system installs. Plain, on-brand slides — the designer can
 * replace these with rich imagery later.
 */
import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    property color bg:     "#14172a"
    property color ink:    "#e8eaf4"
    property color accent: "#ff9d4d"

    function onActivate() { presentation.startTimer() }
    function onLeave()    { presentation.stopTimer() }

    Timer {
        id: advanceTimer
        interval: 7000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: presentation.bg
            Column {
                anchors.centerIn: parent
                spacing: 14
                width: parent.width * 0.7
                Text {
                    text: "Welcome to Dyuti OS"
                    color: presentation.accent
                    font.pixelSize: 34; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "A smooth desktop, made for India."
                    color: presentation.ink
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width; wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: presentation.bg
            Column {
                anchors.centerIn: parent
                spacing: 14
                width: parent.width * 0.7
                Text {
                    text: "Your languages, built in"
                    color: presentation.accent
                    font.pixelSize: 30; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Type and read in Hindi, Tamil, Bengali and more — no setup needed."
                    color: presentation.ink
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width; wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: presentation.bg
            Column {
                anchors.centerIn: parent
                spacing: 14
                width: parent.width * 0.7
                Text {
                    text: "Thousands of apps, one click away"
                    color: presentation.accent
                    font.pixelSize: 30; font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Open the App Center to install your favourite software safely — no terminal required."
                    color: presentation.ink
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width; wrapMode: Text.WordWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
