/*
 * Dyuti OS installer slideshow (Calamares Slideshow API 2).
 * Plays while the system installs. Premium dark, restrained accent — palette
 * and type from design-tokens.md. The designer can replace these with rich
 * imagery later; the structure stays on-brand.
 */
import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    // ---- design tokens -------------------------------------------------------
    property color bg:     "#0d0f12"   // --dy-bg-window
    property color ink:    "#f2f4f7"   // --dy-text-primary
    property color sub:    "#a4adba"   // --dy-text-secondary
    property color accent: "#ff9d4d"   // --dy-accent (restrained: rule only)

    function onActivate() { presentation.startTimer() }
    function onLeave()    { presentation.stopTimer() }

    Timer {
        id: advanceTimer
        interval: 7000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    // ---- a reusable slide: charcoal field, ink title, saffron underline ------
    component InfoSlide: Slide {
        property string heading: ""
        property string body: ""
        Rectangle {
            anchors.fill: parent
            color: presentation.bg
            Column {
                anchors.centerIn: parent
                spacing: 20                       // --dy-space-5
                width: parent.width * 0.66
                Text {
                    text: heading
                    color: presentation.ink
                    font.family: "Inter"
                    font.pixelSize: 30
                    font.weight: Font.Bold
                    font.letterSpacing: -0.5
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                Rectangle {                       // the single restrained accent
                    width: 44; height: 3; radius: 2
                    color: presentation.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: body
                    color: presentation.sub
                    font.family: "Inter"
                    font.pixelSize: 17
                    lineHeight: 1.4
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    InfoSlide {
        heading: "Welcome to Dyuti OS"
        body: "A smooth, premium desktop — made for India."
    }

    InfoSlide {
        heading: "Your languages, built in"
        body: "Type and read in Hindi, Tamil, Bengali and more — no setup needed."
    }

    InfoSlide {
        heading: "Thousands of apps, one click away"
        body: "Open the App Center to install your favourite software safely — no terminal required."
    }
}
