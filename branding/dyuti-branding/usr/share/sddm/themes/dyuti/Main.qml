/*
 * Dyuti OS login screen (SDDM, Theme-API 2.0).
 * Self-contained, minimal, and consistent with the desktop: indigo background,
 * saffron accents, a clean login card. Designer polish lands in Month 2.
 */
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#14172a"

    property color accent: "#ff9d4d"
    property color ink:    "#e8eaf4"

    TextConstants { id: textConstants }

    // ---- background ----------------------------------------------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        clip: true
        Rectangle {              // subtle darken so the card stays readable
            anchors.fill: parent
            color: "#000000"
            opacity: 0.25
        }
    }

    Connections {
        target: sddm
        function onLoginSucceeded() { }
        function onLoginFailed() {
            txtMessage.text = "Login failed — try again"
            password.text = ""
        }
    }

    // ---- login card ----------------------------------------------------------
    Rectangle {
        id: card
        width: 360
        height: 300
        radius: 16
        anchors.centerIn: parent
        color: "#1b1f34"
        opacity: 0.96
        border.color: "#2b2f4a"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 14
            width: 300

            Text {
                text: "Dyuti OS"
                color: root.ink
                font.pixelSize: 30
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextBox {
                id: name
                width: parent.width
                height: 40
                text: userModel.lastUser
                font.pixelSize: 14
                KeyNavigation.tab: password
            }

            PasswordBox {
                id: password
                width: parent.width
                height: 40
                font.pixelSize: 14
                focus: true
                tooltipText: "Password"
                Keys.onReturnPressed: sddm.login(name.text, password.text, session.index)
            }

            Button {
                id: loginButton
                text: "Log In"
                width: parent.width
                height: 40
                color: root.accent
                onClicked: sddm.login(name.text, password.text, session.index)
            }

            Text {
                id: txtMessage
                text: ""
                color: root.accent
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ---- bottom bar: session + power ----------------------------------------
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 16

        ComboBox {
            id: session
            width: 200
            height: 32
            model: sessionModel
            index: sessionModel.lastIndex
            color: "#1b1f34"
            textColor: root.ink
        }

        Button {
            id: rebootButton
            text: "Restart"
            width: 110; height: 32
            onClicked: sddm.reboot()
            visible: sddm.canReboot
        }

        Button {
            id: shutdownButton
            text: "Shut Down"
            width: 110; height: 32
            onClicked: sddm.powerOff()
            visible: sddm.canPowerOff
        }
    }

    Component.onCompleted: {
        if (name.text === "")
            name.focus = true
        else
            password.focus = true
    }
}
