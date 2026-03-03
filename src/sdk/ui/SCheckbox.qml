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
            id: box
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: STheme.radiusSmall
            color: root.checked ? STheme.primary : "transparent"
            border.width: root.checked ? 0 : 2
            border.color: STheme.border

            Behavior on color { ColorAnimation { duration: 150 } }

            SIcon {
                visible: root.checked
                icon: IconCodes.check
                size: 16
                color: STheme.surface
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
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
