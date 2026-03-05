import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Squared.UI

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 700
    title: "Squared Dev"
    color: STheme.background

    Component.onCompleted: {
        SSize.windowWidth = Qt.binding(() => window.width)
        SSize.windowHeight = Qt.binding(() => window.height)
        appRunner.launchFromPath(devAppPath, appContainer)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 32
            color: STheme.surface

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: STheme.spacingSm
                anchors.rightMargin: STheme.spacingSm
                spacing: STheme.spacingSm

                SText {
                    text: "DEV"
                    variant: "caption"
                    color: STheme.primary
                    font.bold: true
                }

                SText {
                    text: devAppPath
                    variant: "caption"
                    Layout.fillWidth: true
                    elide: Text.ElideMiddle
                    color: STheme.textSecondary
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: STheme.border
            }
        }

        Item {
            id: appContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
