import QtQuick

Rectangle {
    id: root

    property url source: ""
    property string initials: ""
    property int size: 40

    implicitWidth: size
    implicitHeight: size
    radius: width / 2
    color: img.visible ? "transparent" : STheme.primaryVariant
    clip: true

    SText {
        visible: !img.visible
        text: root.initials.toUpperCase()
        color: STheme.surface
        font.pixelSize: root.size * 0.4
        font.weight: Font.DemiBold
        anchors.centerIn: parent
    }

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        visible: root.source.toString() !== "" && status === Image.Ready
        fillMode: Image.PreserveAspectCrop
    }
}
