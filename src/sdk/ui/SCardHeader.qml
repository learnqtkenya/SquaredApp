import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    property string subtitle: ""

    Layout.fillWidth: true
    spacing: STheme.spacingXs

    SText {
        text: root.title
        variant: "subheading"
    }

    SText {
        visible: root.subtitle !== ""
        text: root.subtitle
        variant: "caption"
        color: STheme.textSecondary
    }
}
