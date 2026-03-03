import QtQuick

Rectangle {
    id: root

    property string text: ""
    property color textColor: STheme.surface
    property color badgeColor: STheme.primary

    implicitWidth: label.implicitWidth + STheme.spacingSm * 2
    implicitHeight: label.implicitHeight + STheme.spacingXs
    radius: height / 2
    color: badgeColor

    SText {
        id: label
        text: root.text
        variant: "caption"
        color: root.textColor
        anchors.centerIn: parent
        font.weight: Font.DemiBold
    }
}
