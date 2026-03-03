import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var value: ""
    property string label: ""
    property string icon: ""

    spacing: STheme.spacingXs

    SIcon {
        visible: root.icon !== ""
        icon: root.icon
        size: 28
        color: STheme.primary
        Layout.alignment: Qt.AlignHCenter
    }

    SText {
        text: String(root.value)
        variant: "heading"
        horizontalAlignment: Text.AlignHCenter
    }

    SText {
        text: root.label
        variant: "caption"
        color: STheme.textSecondary
        horizontalAlignment: Text.AlignHCenter
    }
}
