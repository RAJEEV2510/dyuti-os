/*
 * Dyuti OS — first-boot Welcome / onboarding.
 * A polished, on-brand multi-step intro. Skeleton: the steps are real screens;
 * deep actions (launch settings, install bundles) get wired to a native helper
 * in Month 2. Run with: qmlscene Welcome.qml
 */
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: win
    visible: true
    width: 860
    height: 560
    minimumWidth: 720
    minimumHeight: 480
    title: "Welcome to Dyuti OS"
    color: "#14172a"

    readonly property color ink:    "#e8eaf4"
    readonly property color sub:    "#9aa0bf"
    readonly property color accent: "#ff9d4d"
    readonly property color card:   "#1b1f34"

    // ---- content steps -------------------------------------------------------
    property var steps: [
        { title: "Welcome to Dyuti OS",
          body:  "A smooth, beautiful desktop — made for India.\nLet's get you set up in under a minute." },
        { title: "Your languages, built in",
          body:  "Read and type in Hindi, Tamil, Bengali and more.\nSwitch input methods anytime from the system tray." },
        { title: "Thousands of apps, one click",
          body:  "Open the App Center to install software safely —\nno terminal, no hunting around the web." },
        { title: "Make it yours",
          body:  "Change the look, layout and wallpaper in System Settings.\nDyuti is yours to shape." },
        { title: "You're all set",
          body:  "Enjoy Dyuti OS. You can reopen this guide anytime\nfrom the application menu." }
    ]
    property int index: 0

    SwipeView {
        id: view
        anchors.fill: parent
        anchors.bottomMargin: 84
        currentIndex: win.index
        interactive: true
        onCurrentIndexChanged: win.index = currentIndex

        Repeater {
            model: win.steps
            delegate: Item {
                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.78, 620)
                    spacing: 18

                    Rectangle {            // emblem placeholder (designer art later)
                        Layout.alignment: Qt.AlignHCenter
                        width: 84; height: 84; radius: 42
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#ffd27a" }
                            GradientStop { position: 1.0; color: "#ff9d4d" }
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.title
                        color: win.ink
                        font.pixelSize: 30
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.body
                        color: win.sub
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        lineHeight: 1.2
                    }
                }
            }
        }
    }

    // ---- page dots -----------------------------------------------------------
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        spacing: 8
        Repeater {
            model: win.steps.length
            delegate: Rectangle {
                width: 9; height: 9; radius: 5
                color: index === win.index ? win.accent : "#3a3f5c"
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    // ---- nav bar -------------------------------------------------------------
    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 18
        height: 48

        Button {
            text: "Back"
            visible: win.index > 0
            onClicked: win.index = Math.max(0, win.index - 1)
            flat: true
        }
        Item { Layout.fillWidth: true }
        Button {
            text: win.index === win.steps.length - 1 ? "Finish" : "Next"
            highlighted: true
            onClicked: {
                if (win.index === win.steps.length - 1)
                    win.close()
                else
                    win.index = win.index + 1
            }
        }
    }
}
