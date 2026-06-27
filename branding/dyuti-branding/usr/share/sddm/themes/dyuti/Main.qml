/*
 * Dyuti OS login screen (SDDM, Theme-API 2.0).
 * Premium charcoal, restrained saffron accent. Blurred wallpaper, a single
 * centered surface-3 card (radius-lg, elev-4), one saffron CTA. Colors and
 * geometry come straight from design-tokens.md (dark theme).
 */
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0d0f12"                       // --dy-bg-window

    // ---- design tokens -------------------------------------------------------
    property color cBgWindow:  "#0d0f12"
    property color cSunken:    "#08090b"
    property color cSurface3:  "#232831"
    property color cBorder:    "#262b33"
    property color cBorderStr: "#3a414c"
    property color cText:      "#f2f4f7"
    property color cTextSec:   "#a4adba"
    property color accent:     "#ff9d4d"
    property color accentHov:  "#ffad66"
    property color accentInk:  "#1a1206"   // text on saffron; name must NOT start with "on" (QML signal-handler clash)

    TextConstants { id: textConstants }

    // ---- background: wallpaper, dimmed for card legibility -------------------
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        clip: true
    }
    Rectangle {                            // --dy-overlay-scrim, keeps card readable
        anchors.fill: parent
        color: "#000000"
        opacity: 0.45
    }

    Connections {
        target: sddm
        function onLoginSucceeded() { }
        function onLoginFailed() {
            txtMessage.text = "Login failed — try again"
            password.text = ""
        }
    }

    // ---- login card (surface-3, radius-lg, elev-4) --------------------------
    Rectangle {
        id: card
        width: 380
        height: 348
        radius: 14                         // --dy-radius-lg
        anchors.centerIn: parent
        color: root.cSurface3
        border.color: root.cBorder
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: 312

            // avatar placeholder
            Rectangle {
                width: 72; height: 72; radius: 36
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#1b1f26"
                border.color: root.cBorderStr
                border.width: 2
            }

            Text {
                text: "Dyuti OS"
                color: root.cText
                font.family: "Inter"
                font.pixelSize: 24
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextBox {
                id: name
                width: parent.width
                height: 44
                text: userModel.lastUser
                font.pixelSize: 14
                color: root.cSunken
                borderColor: root.cBorderStr
                focusColor: root.accent
                textColor: root.cText
                KeyNavigation.tab: password
            }

            PasswordBox {
                id: password
                width: parent.width
                height: 44
                font.pixelSize: 14
                focus: true
                color: root.cSunken
                borderColor: root.cBorderStr
                focusColor: root.accent
                textColor: root.cText
                tooltipText: "Password"
                Keys.onReturnPressed: sddm.login(name.text, password.text, session.index)
            }

            Button {
                id: loginButton
                text: "Log In"
                width: parent.width
                height: 44
                color: root.accent
                activeColor: root.accentHov
                pressedColor: root.accentHov
                textColor: root.accentInk
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
            height: 36
            model: sessionModel
            index: sessionModel.lastIndex
            color: root.cSurface3
            textColor: root.cText
            borderColor: root.cBorder
        }

        Button {
            id: rebootButton
            text: "Restart"
            width: 110; height: 36
            color: root.cSurface3
            textColor: root.cText
            onClicked: sddm.reboot()
            visible: sddm.canReboot
        }

        Button {
            id: shutdownButton
            text: "Shut Down"
            width: 120; height: 36
            color: root.cSurface3
            textColor: root.cText
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
