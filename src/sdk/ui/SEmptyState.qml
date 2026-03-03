import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string icon: ""
    property string title: ""
    property string description: ""
    property string actionText: ""

    signal actionClicked()

    spacing: STheme.spacingMd

    SIcon {
        visible: root.icon !== ""
        icon: root.icon
        size: 64
        color: STheme.textSecondary
        Layout.alignment: Qt.AlignHCenter
    }

    SText {
        visible: root.title !== ""
        text: root.title
        variant: "subheading"
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
    }

    SText {
        visible: root.description !== ""
        text: root.description
        variant: "body"
        color: STheme.textSecondary
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
    }

    Item { Layout.preferredHeight: STheme.spacingSm }

    SButton {
        visible: root.actionText !== ""
        text: root.actionText
        style: "Primary"
        Layout.alignment: Qt.AlignHCenter
        onClicked: root.actionClicked()
    }
}
