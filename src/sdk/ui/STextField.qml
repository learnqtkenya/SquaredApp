import QtQuick
import QtQuick.Controls

TextField {
    id: root

    implicitWidth: 280
    implicitHeight: 44

    font: STheme.body
    color: STheme.text
    placeholderTextColor: STheme.textSecondary
    selectionColor: STheme.primary
    selectedTextColor: STheme.surface
    leftPadding: STheme.spacingMd
    rightPadding: STheme.spacingMd

    background: Rectangle {
        radius: STheme.radiusSmall
        color: STheme.surface
        border.width: root.activeFocus ? 2 : 1
        border.color: root.activeFocus ? STheme.primary : STheme.border

        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
    }
}
