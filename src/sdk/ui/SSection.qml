import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    property bool showDivider: true
    default property alias content: contentColumn.data

    spacing: STheme.spacingSm
    Layout.fillWidth: true

    SText {
        visible: root.title !== ""
        text: root.title
        variant: "subheading"
        Layout.fillWidth: true
    }

    SDivider {
        visible: root.showDivider
        Layout.fillWidth: true
    }

    ColumnLayout {
        id: contentColumn
        Layout.fillWidth: true
        spacing: STheme.spacingSm
    }
}
