import QtQuick

Item {
    id: root

    property int size: 32
    property color color: STheme.primary
    property bool running: true

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: spinner
        width: root.size
        height: root.size
        radius: root.size / 2
        color: "transparent"
        border.width: 3
        border.color: STheme.border
        anchors.centerIn: parent

        Rectangle {
            width: parent.width
            height: parent.height
            radius: parent.radius
            color: "transparent"
            border.width: 3
            border.color: root.color
            anchors.centerIn: parent

            // Arc mask: only show a quarter of the border
            layer.enabled: true
            layer.effect: null
            visible: false
        }

        // Simpler approach: rotating arc indicator
        Canvas {
            id: arc
            anchors.fill: parent
            antialiasing: true

            property real angle: 0

            onAngleChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = root.color
                ctx.lineWidth = 3
                ctx.lineCap = "round"
                ctx.beginPath()
                var startAngle = angle * Math.PI / 180
                ctx.arc(width / 2, height / 2, width / 2 - 2, startAngle, startAngle + Math.PI * 1.5)
                ctx.stroke()
            }

            RotationAnimation on angle {
                running: root.running
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }
    }
}
