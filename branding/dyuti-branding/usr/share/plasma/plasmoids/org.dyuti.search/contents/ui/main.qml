/*
 * Dyuti Search — a clean, modern search flyout for the panel.
 *
 * ARCHITECTURE (and why it is the way it is):
 *  An inline, always-visible text field embedded in a Plasma PANEL cannot grab
 *  the keyboard at the window-manager level — a panel is a "dock" window the WM
 *  never focuses, so typed characters leak to the desktop and Plasma's "type to
 *  search" pops KRunner at the TOP of the screen. The reliable pattern — the one
 *  Kickoff and KRunner themselves use — is a POPUP: the panel shows a compact
 *  "pill"; clicking it opens the plasmoid's full representation as a real
 *  focusable window directly ABOVE the pill. The field lives IN that popup, so it
 *  owns the keyboard, and results render right there — never the KRunner overlay.
 *
 *  FEELS INLINE: the popup opens on a SINGLE click and the input is pre-focused
 *  (Qt.callLater, one frame after the popup window maps) so you just start
 *  typing. The input sits flush at the BOTTOM of the popup — right above the pill,
 *  same pill styling — so the pill appears to grow upward into the search rather
 *  than spawning a separate box. Results grow UP above the input (reversed), best
 *  match nearest the field. Clean rows replace Milou's dated category gutter.
 *
 * Base: Plasma 5.27 / Qt5. Milou ships org.kde.milou (the KRunner results model).
 */
import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.milou 0.3 as Milou

Item {
    id: root

    // Panel shows the compact pill; clicking it opens the popup (full rep).
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    // ── Compact: the pill button shown in the panel ────────────────────────
    Plasmoid.compactRepresentation: Item {
        id: compact
        Layout.minimumWidth: PlasmaCore.Units.gridUnit * 7
        Layout.preferredWidth: PlasmaCore.Units.gridUnit * 9
        Layout.maximumWidth: PlasmaCore.Units.gridUnit * 11

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: PlasmaCore.Units.smallSpacing
            anchors.bottomMargin: PlasmaCore.Units.smallSpacing
            radius: height / 2                       // full rounded capsule
            // While the popup is open, the input above IS the search box, so the
            // pill blends away (transparent, no border, label hidden) — one box,
            // not two stacked boxes.
            color: Plasmoid.expanded ? "transparent" : PlasmaCore.Theme.backgroundColor
            border.width: 1
            border.color: Plasmoid.expanded
                ? "transparent"
                : (compactMouse.containsMouse
                    ? PlasmaCore.Theme.highlightColor
                    : Qt.rgba(PlasmaCore.Theme.textColor.r, PlasmaCore.Theme.textColor.g, PlasmaCore.Theme.textColor.b, 0.18))
            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on border.color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: PlasmaCore.Units.gridUnit * 0.5
                anchors.rightMargin: PlasmaCore.Units.smallSpacing
                spacing: PlasmaCore.Units.smallSpacing

                PlasmaCore.IconItem {
                    source: "search"
                    Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                    Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
                    Layout.alignment: Qt.AlignVCenter
                    opacity: Plasmoid.expanded ? 0.35 : 0.7
                }
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: i18n("Search")
                    opacity: 0.55
                    elide: Text.ElideRight
                    visible: !Plasmoid.expanded          // hide while popup is open
                }
            }

            MouseArea {
                id: compactMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Plasmoid.expanded = !Plasmoid.expanded
            }
        }
    }

    // ── Full: the popup (a real focusable window) above the pill ────────────
    Plasmoid.fullRepresentation: Item {
        id: full
        Layout.minimumWidth: PlasmaCore.Units.gridUnit * 22
        Layout.preferredWidth: PlasmaCore.Units.gridUnit * 24
        // Just the field when idle; grows tall once you start typing.
        Layout.minimumHeight: PlasmaCore.Units.gridUnit * 2.8
        Layout.preferredHeight: full.query.length > 0
            ? PlasmaCore.Units.gridUnit * 26
            : PlasmaCore.Units.gridUnit * 2.8

        readonly property string query: field.text

        // Pre-focus one frame after the popup maps, so a single click -> type.
        function focusField() { field.forceActiveFocus() }
        Connections {
            target: Plasmoid
            function onExpandedChanged() {
                if (Plasmoid.expanded) {
                    field.text = ""
                    Qt.callLater(full.focusField)
                }
            }
        }
        Component.onCompleted: Qt.callLater(full.focusField)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: PlasmaCore.Units.smallSpacing
            spacing: PlasmaCore.Units.smallSpacing

            // ── Results: Milou's model, our clean rows, growing UP ─────────
            Milou.ResultsView {
                id: resultsView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: full.query.length > 0
                clip: true
                reversed: true                       // best match nearest the field
                queryString: full.query
                onActivated: Plasmoid.expanded = false   // ran something -> close

                // Clean flat row: rounded highlight + icon + name + subtext.
                delegate: MouseArea {
                    id: row
                    width: ListView.view ? ListView.view.width : 0
                    height: PlasmaCore.Units.gridUnit * 2.6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { ListView.view.currentIndex = index; ListView.view.runCurrentIndex() }
                    onContainsMouseChanged: if (containsMouse) ListView.view.currentIndex = index

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 1
                        anchors.bottomMargin: 1
                        radius: PlasmaCore.Units.smallSpacing
                        color: PlasmaCore.Theme.highlightColor
                        opacity: row.ListView.isCurrentItem ? 0.22 : 0
                        Behavior on opacity { NumberAnimation { duration: 80 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: PlasmaCore.Units.gridUnit * 0.6
                        anchors.rightMargin: PlasmaCore.Units.gridUnit * 0.6
                        spacing: PlasmaCore.Units.gridUnit * 0.6

                        PlasmaCore.IconItem {
                            Layout.preferredWidth: PlasmaCore.Units.iconSizes.medium
                            Layout.preferredHeight: PlasmaCore.Units.iconSizes.medium
                            Layout.alignment: Qt.AlignVCenter
                            source: model.decoration
                            usesPlasmaTheme: false
                            animated: false
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0
                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: String(model.display)
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                visible: text.length > 0
                                text: String(model.subtext || "")
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                opacity: 0.55
                                font.pointSize: PlasmaCore.Theme.smallestFont.pointSize
                            }
                        }
                    }
                }
            }

            // ── The search field — flush at the BOTTOM, styled like the pill ─
            Rectangle {
                id: inputBox
                Layout.fillWidth: true
                Layout.preferredHeight: PlasmaCore.Units.gridUnit * 2.2
                radius: height / 2
                color: PlasmaCore.Theme.viewBackgroundColor
                border.width: 1
                border.color: field.activeFocus
                    ? PlasmaCore.Theme.highlightColor
                    : Qt.rgba(PlasmaCore.Theme.textColor.r, PlasmaCore.Theme.textColor.g, PlasmaCore.Theme.textColor.b, 0.22)
                Behavior on border.color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: PlasmaCore.Units.gridUnit * 0.6
                    anchors.rightMargin: PlasmaCore.Units.gridUnit * 0.6
                    spacing: PlasmaCore.Units.smallSpacing

                    PlasmaCore.IconItem {
                        source: "search"
                        Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                        Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
                        Layout.alignment: Qt.AlignVCenter
                        opacity: 0.7
                    }
                    PlasmaComponents3.TextField {
                        id: field
                        focus: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        background: Item {}
                        leftPadding: 0
                        rightPadding: 0
                        placeholderText: i18n("Search apps, files, settings…")
                        // Results are ABOVE the field: Up walks up into them.
                        Keys.onUpPressed: resultsView.incrementCurrentIndex()
                        Keys.onDownPressed: resultsView.decrementCurrentIndex()
                        Keys.onEscapePressed: Plasmoid.expanded = false
                        onAccepted: if (text.length > 0) resultsView.runCurrentIndex()
                    }
                }
            }
        }
    }
}
