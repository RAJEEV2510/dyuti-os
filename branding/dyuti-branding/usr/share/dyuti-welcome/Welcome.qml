/*
 * Dyuti OS — first-boot Welcome / onboarding.
 * A polished, on-brand multi-step intro. Skeleton: the steps are real screens;
 * deep actions (launch settings, install bundles) get wired to a native helper
 * in Month 2. Run with: qmlscene Welcome.qml
 *
 * Palette + type read from design-tokens.md (premium dark, restrained saffron).
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

    // ---- design tokens -------------------------------------------------------
    readonly property color bgWindow:   "#0d0f12"   // --dy-bg-window
    readonly property color surface3:   "#232831"   // --dy-surface-3
    readonly property color ink:        "#f2f4f7"   // --dy-text-primary
    readonly property color sub:        "#a4adba"   // --dy-text-secondary
    readonly property color borderStr:  "#3a414c"   // --dy-border-strong
    readonly property color accent:     "#ff9d4d"   // --dy-accent
    readonly property color accentHov:  "#ffad66"   // --dy-accent-hover
    readonly property color accentInk:  "#1a1206"   // --dy-on-accent (text on saffron; name must NOT start with "on")
    readonly property string uiFont:    "Inter"

    color: bgWindow

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
        anchors.bottomMargin: 88
        currentIndex: win.index
        interactive: true
        onCurrentIndexChanged: win.index = currentIndex

        Repeater {
            model: win.steps
            delegate: Item {
                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.78, 620)
                    spacing: 24                       // --dy-space-6 section gap

                    Rectangle {            // brand emblem (the one accent focal)
                        Layout.alignment: Qt.AlignHCenter
                        width: 84; height: 84; radius: 42
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: win.accentHov }
                            GradientStop { position: 1.0; color: win.accent }
                        }
                    }
                    Label {                           // H1: 32px / 700 / -0.02em
                        Layout.fillWidth: true
                        text: modelData.title
                        color: win.ink
                        font.family: win.uiFont
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        font.letterSpacing: -0.6
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Label {                           // Body Large: 16 / 24 / 400
                        Layout.fillWidth: true
                        text: modelData.body
                        color: win.sub
                        font.family: win.uiFont
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        lineHeight: 1.5
                    }
                }
            }
        }
    }

    // ---- page dots -----------------------------------------------------------
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 52
        spacing: 8                                    // --dy-space-2
        Repeater {
            model: win.steps.length
            delegate: Rectangle {
                width: 9; height: 9; radius: 5
                color: index === win.index ? win.accent : win.borderStr
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    // ---- nav bar -------------------------------------------------------------
    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24                           // --dy-space-6
        height: 48

        // Secondary action: neutral, text-only (per §3 — only one accent CTA).
        Button {
            id: backBtn
            text: "Back"
            visible: win.index > 0
            flat: true
            onClicked: win.index = Math.max(0, win.index - 1)
            contentItem: Text {
                text: backBtn.text
                font.family: win.uiFont
                font.pixelSize: 14
                color: backBtn.down ? win.ink : win.sub
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { color: "transparent" }
        }

        Item { Layout.fillWidth: true }

        // Primary CTA: the single saffron fill on the screen.
        Button {
            id: nextBtn
            text: win.index === win.steps.length - 1 ? "Finish" : "Next"
            onClicked: {
                if (win.index === win.steps.length - 1)
                    win.close()
                else
                    win.index = win.index + 1
            }
            contentItem: Text {
                text: nextBtn.text
                font.family: win.uiFont
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: win.accentInk
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                implicitWidth: 104
                implicitHeight: 36
                radius: 6                              // --dy-radius-sm
                color: nextBtn.down ? "#f08a35"        // --dy-accent-pressed
                     : nextBtn.hovered ? win.accentHov
                     : win.accent
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }
    }
}
