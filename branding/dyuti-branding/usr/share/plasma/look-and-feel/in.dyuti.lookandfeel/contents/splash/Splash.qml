/*
 * Dyuti OS — Plasma startup splash (login → desktop).
 * Replaces the default KDE splash. Indigo background, a glowing radiance mark,
 * and the product name. `stage` is driven by ksplashqml (0..6).
 */
import QtQuick 2.5

Rectangle {
    id: root
    color: "#14172a"
    anchors.fill: parent

    property int stage
    onStageChanged: {
        if (stage == 1) { content.opacity = 1.0 }
        if (stage == 5) { /* nearly ready */ }
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: 22
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

        // glowing radiance dot
        Rectangle {
            width: 96; height: 96; radius: 48
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffe7b0" }
                GradientStop { position: 1.0; color: "#ff9d4d" }
            }
            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.08; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.08; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
            }
        }

        Text {
            text: "Dyuti OS"
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#e8eaf4"
            font.pixelSize: 34
            font.bold: true
        }
    }

    // subtle progress ticks at the bottom
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8
        Repeater {
            model: 6
            Rectangle {
                width: 8; height: 8; radius: 4
                color: index < root.stage ? "#ff9d4d" : "#2b2f4a"
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
