/*
 * Dyuti Task View — a panel button that opens the full-screen Overview
 * (a full desktop/window overview): desktop cards, "+ New desktop", window thumbnails.
 * Click -> triggers KWin's "Overview" shortcut over D-Bus. No polling.
 * Base: Plasma 5.27 / Qt5.
 */
import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    // Force the full representation so the icon shows inline AND our click handler
    // runs Overview directly (a compact icon would instead open a popup).
    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    // Fixed-size square button. NO self-referential binding (a previous version
    // bound preferredWidth to root.height, which created a sizing loop and the
    // applet failed to load + collapsed the panel).
    Layout.minimumWidth: PlasmaCore.Units.iconSizes.medium
    Layout.preferredWidth: PlasmaCore.Units.iconSizes.large
    Layout.maximumWidth: PlasmaCore.Units.iconSizes.large

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) { disconnectSource(source) }
        function run(cmd) { connectSource(cmd) }
    }

    PlasmaCore.IconItem {
        anchors.fill: parent
        anchors.margins: PlasmaCore.Units.smallSpacing
        // Custom Dyuti Task View glyph (shipped in the package) so the icon theme
        // can't restyle it into a generic window-duplicate look.
        source: Qt.resolvedUrl("../icons/taskview.svg")
        active: mouse.containsMouse

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: executable.run(
                "qdbus org.kde.kglobalaccel /component/kwin " +
                "org.kde.kglobalaccel.Component.invokeShortcut Overview")
        }
    }
}
