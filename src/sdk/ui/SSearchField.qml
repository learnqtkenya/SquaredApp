import QtQuick
import QtQuick.Controls

TextField {
    id: root

    implicitWidth: 280
    implicitHeight: 44
    leftPadding: STheme.spacingMd + searchIcon.width + STheme.spacingSm
    rightPadding: clearButton.visible ? clearButton.width + STheme.spacingSm : STheme.spacingMd

    font: STheme.body
    color: STheme.text
    placeholderText: "Search..."
    placeholderTextColor: STheme.textSecondary
    selectionColor: STheme.primary
    selectedTextColor: STheme.surface

    background: Rectangle {
        radius: STheme.radiusSmall
        color: STheme.surface
        border.width: root.activeFocus ? 2 : 1
        border.color: root.activeFocus ? STheme.primary : STheme.border

        SIcon {
            id: searchIcon
            icon: IconCodes.search
            size: 20
            color: STheme.textSecondary
            anchors.verticalCenter: parent.verticalCenter
            x: STheme.spacingMd
        }

        SIcon {
            id: clearButton
            visible: root.text.length > 0
            icon: IconCodes.close
            size: 20
            color: STheme.textSecondary
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: STheme.spacingSm

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                onClicked: root.clear()
            }
        }
    }
}
