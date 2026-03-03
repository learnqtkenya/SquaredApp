import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AbstractButton {
    id: root

    property string style: "Primary"
    property string iconSource: ""

    implicitWidth: Math.max(contentRow.implicitWidth + STheme.spacingLg, 44)
    implicitHeight: 44

    opacity: enabled ? 1.0 : 0.5

    background: Rectangle {
        radius: STheme.radiusSmall
        color: {
            if (!root.enabled) return STheme.border
            switch (root.style) {
            case "Primary": return root.pressed ? STheme.primaryVariant : STheme.primary
            case "Secondary": return root.pressed ? STheme.border : STheme.surfaceVariant
            case "Ghost": return root.pressed ? STheme.surfaceVariant : "transparent"
            case "Danger": return root.pressed ? "#DC2626" : STheme.error
            default: return STheme.primary
            }
        }
        border.width: root.style === "Secondary" ? 1 : 0
        border.color: STheme.border

        Behavior on color { ColorAnimation { duration: 100 } }
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.iconSource !== "" ? STheme.spacingSm : 0

            SIcon {
                visible: root.iconSource !== ""
                icon: root.iconSource
                size: 18
                color: {
                    switch (root.style) {
                    case "Primary": return STheme.surface
                    case "Danger": return STheme.surface
                    case "Secondary": return STheme.text
                    case "Ghost": return STheme.text
                    default: return STheme.surface
                    }
                }
                Layout.alignment: Qt.AlignVCenter
            }

            SText {
                text: root.text
                variant: "body"
                color: {
                    switch (root.style) {
                    case "Primary": return STheme.surface
                    case "Danger": return STheme.surface
                    case "Secondary": return STheme.text
                    case "Ghost": return STheme.text
                    default: return STheme.surface
                    }
                }
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
