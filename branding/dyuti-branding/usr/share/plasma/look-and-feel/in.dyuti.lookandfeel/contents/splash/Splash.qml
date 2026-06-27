/*
 * Dyuti OS — Plasma startup splash (login → desktop).
 * Premium charcoal field, a single restrained saffron radiance mark, and the
 * product name. Colors from design-tokens.md (dark). `stage` is driven by
 * ksplashqml (0..6) and fills a thin saffron progress hairline.
 */
import QtQuick 2.5

Rectangle {
    id: root
    color: "#08090b"                       // --dy-bg-sunken
    anchors.fill: parent

    property int stage

    onStageChanged: {
        if (stage == 1) { content.opacity = 1.0 }
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: 24
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

        // Restrained radiance mark: charcoal disc with a saffron core glow.
        Item {
            width: 96; height: 96
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {                    // soft saffron halo
                anchors.centerIn: parent
                width: 96; height: 96; radius: 48
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#ff9d4d" }
                    GradientStop { position: 0.55; color: "#3a2410" }
                    GradientStop { position: 1.0; color: "#08090b" }
                }
                opacity: 0.9
            }
            Rectangle {                    // bright core
                anchors.centerIn: parent
                width: 30; height: 30; radius: 15
                color: "#ffd9b0"
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.7; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.7; duration: 900; easing.type: Easing.InOutSine }
                }
            }
        }

        Text {
            text: "Dyuti OS"
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#f2f4f7"               // --dy-text-primary
            font.family: "Inter"
            font.pixelSize: 30
            font.weight: Font.DemiBold
        }
    }

    // Thin saffron progress hairline near the bottom (--dy-accent on a subtle track).
    Rectangle {
        id: track
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        width: 220; height: 2; radius: 1
        color: "#262b33"                   // --dy-border-subtle

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.min(root.stage / 6.0, 1.0)
            radius: 1
            color: "#ff9d4d"               // --dy-accent
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }
    }
}
