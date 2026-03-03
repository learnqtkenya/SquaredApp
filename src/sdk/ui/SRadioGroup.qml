import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var model: []
    property int currentIndex: -1

    signal selected(int index)

    spacing: STheme.spacingSm

    Repeater {
        model: root.model

        Item {
            Layout.fillWidth: true
            implicitHeight: 32

            RowLayout {
                id: row
                spacing: STheme.spacingSm
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    radius: 11
                    color: "transparent"
                    border.width: 2
                    border.color: index === root.currentIndex ? STheme.primary : STheme.border

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: STheme.primary
                        anchors.centerIn: parent
                        visible: index === root.currentIndex
                        scale: index === root.currentIndex ? 1.0 : 0.0

                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        onClicked: () => {
                            root.currentIndex = index
                            root.selected(index)
                        }
                    }
                }

                SText {
                    text: modelData
                    variant: "body"
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
