import QtQuick
import QtQuick.Controls

Slider {
    id: root

    implicitWidth: 280
    implicitHeight: 32

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 4
        radius: 2
        color: STheme.border

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: STheme.primary
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 24
        height: 24
        radius: 12
        color: root.pressed ? STheme.primaryVariant : STheme.primary
        border.width: 2
        border.color: STheme.surface

        Behavior on color { ColorAnimation { duration: 100 } }
    }
}
