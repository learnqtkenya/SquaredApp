import QtQuick
import QtQuick.Layouts

GridLayout {
    id: root

    property int minColumnWidth: 150

    columns: Math.max(1, Math.floor((parent ? parent.width : 300) / minColumnWidth))
    columnSpacing: STheme.spacingMd
    rowSpacing: STheme.spacingMd
}
