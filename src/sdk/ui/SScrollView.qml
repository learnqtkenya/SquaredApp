import QtQuick
import QtQuick.Controls

ScrollView {
    id: root

    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    background: Rectangle {
        color: "transparent"
    }
}
