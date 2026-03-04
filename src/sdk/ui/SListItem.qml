import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property alias trailing: trailingLoader.sourceComponent

    signal clicked()

    Layout.fillWidth: true
    implicitWidth: 300
    implicitHeight: Math.max(contentRow.implicitHeight + STheme.spacingSm * 2, 44)
    color: mouseArea.pressed ? STheme.surfaceVariant : "transparent"
    radius: STheme.radiusSmall

    Behavior on color { ColorAnimation { duration: 100 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: STheme.spacingSm
        spacing: STheme.spacingMd

        SIcon {
            visible: root.icon !== ""
            icon: root.icon
            size: 24
            color: STheme.textSecondary
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: STheme.spacingXs

            SText {
                text: root.title
                variant: "body"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            SText {
                visible: root.subtitle !== ""
                text: root.subtitle
                variant: "caption"
                color: STheme.textSecondary
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Loader {
            id: trailingLoader
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
