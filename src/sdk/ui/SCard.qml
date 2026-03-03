import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    default property alias content: column.data

    Layout.fillWidth: true
    implicitWidth: 300
    implicitHeight: column.implicitHeight + STheme.spacingMd * 2
    radius: STheme.radiusMedium
    color: STheme.surface
    border.width: 1
    border.color: STheme.border

    ColumnLayout {
        id: column
        x: STheme.spacingMd
        y: STheme.spacingMd
        width: root.width - STheme.spacingMd * 2
    }
}
