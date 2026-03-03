import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string title: ""
    default property alias content: contentColumn.data
    property string acceptText: "OK"
    property string rejectText: "Cancel"
    property bool showReject: true
    property bool opened: false

    signal accepted()
    signal rejected()

    function open() { root.opened = true }
    function close() { root.opened = false }

    visible: opened
    anchors.fill: parent
    z: 999

    // Overlay
    Rectangle {
        anchors.fill: parent
        color: "#80000000"

        MouseArea {
            anchors.fill: parent
            onClicked: () => {
                root.rejected()
                root.close()
            }
        }
    }

    // Dialog card
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - STheme.spacingXl * 2, 340)
        height: dialogColumn.implicitHeight + STheme.spacingLg * 2
        radius: STheme.radiusLarge
        color: STheme.surface

        ColumnLayout {
            id: dialogColumn
            anchors.fill: parent
            anchors.margins: STheme.spacingLg
            spacing: STheme.spacingMd

            SText {
                visible: root.title !== ""
                text: root.title
                variant: "subheading"
                Layout.fillWidth: true
            }

            ColumnLayout {
                id: contentColumn
                Layout.fillWidth: true
                spacing: STheme.spacingSm
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: STheme.spacingSm
                layoutDirection: Qt.RightToLeft

                SButton {
                    text: root.acceptText
                    style: "Primary"
                    onClicked: () => {
                        root.accepted()
                        root.close()
                    }
                }

                SButton {
                    visible: root.showReject
                    text: root.rejectText
                    style: "Ghost"
                    onClicked: () => {
                        root.rejected()
                        root.close()
                    }
                }
            }
        }
    }
}
