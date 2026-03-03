import QtQuick

Item {
    id: root

    property real value: 0.0
    property bool indeterminate: false

    implicitWidth: 280
    implicitHeight: 6

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: STheme.border
        clip: true

        Rectangle {
            id: fill
            height: parent.height
            radius: parent.radius
            color: STheme.primary
            width: root.indeterminate ? parent.width * 0.3 : parent.width * Math.max(0, Math.min(1, root.value))

            Behavior on width {
                enabled: !root.indeterminate
                NumberAnimation { duration: 200 }
            }

            SequentialAnimation on x {
                running: root.indeterminate
                loops: Animation.Infinite
                NumberAnimation {
                    from: -fill.width
                    to: track.width
                    duration: 1200
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
