import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool checked: false
    property bool enabled: true
    property string text: ""

    signal toggled()

    implicitWidth: row.implicitWidth
    implicitHeight: 32
    opacity: enabled ? 1.0 : 0.5

    RowLayout {
        id: row
        spacing: STheme.spacingSm
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: track
            Layout.preferredWidth: 48
            Layout.preferredHeight: 28
            radius: 14
            color: root.checked ? STheme.primary : STheme.border

            Behavior on color { ColorAnimation { duration: 150 } }

            Rectangle {
                id: thumb
                width: 22
                height: 22
                radius: 11
                color: STheme.surface
                y: 3
                x: root.checked ? parent.width - width - 3 : 3

                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.enabled
                onClicked: () => {
                    root.checked = !root.checked
                    root.toggled()
                }
            }
        }

        SText {
            visible: root.text !== ""
            text: root.text
            variant: "body"
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
