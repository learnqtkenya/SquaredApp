import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    default property alias content: contentColumn.data

    color: STheme.background

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: STheme.spacingMd
        spacing: STheme.spacingMd

        SText {
            visible: root.title !== ""
            text: root.title
            variant: "heading"
            Layout.fillWidth: true
        }
    }
}
