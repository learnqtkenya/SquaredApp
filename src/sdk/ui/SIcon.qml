import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string icon: ""
    property int size: 24
    property alias color: label.color

    implicitWidth: size
    implicitHeight: size
    Layout.preferredWidth: size
    Layout.preferredHeight: size
    Layout.maximumWidth: size
    Layout.maximumHeight: size

    Text {
        id: label
        anchors.fill: parent
        text: root.icon
        font.family: "Material Symbols Outlined"
        font.pixelSize: root.size
        font.weight: Font.Normal
        color: STheme.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
