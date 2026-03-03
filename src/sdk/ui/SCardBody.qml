import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    default property alias content: root.data

    Layout.fillWidth: true
    spacing: STheme.spacingSm
}
