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

    Connections {
        target: appRunner
        function onReloadRequested() {
            reloadIndicator.show()
            appRunner.launchFromPath(devAppPath, appContainer)
        }
        function onError(appId, message) {
            errorText.text = message
            errorText.visible = true
        }
        function onLaunched() {
            errorText.visible = false
        }
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

                // Reload indicator
                SText {
                    id: reloadIndicator
                    text: "reloaded"
                    variant: "caption"
                    color: STheme.success
                    opacity: 0

                    function show() {
                        opacity = 1
                        fadeOut.restart()
                    }

                    NumberAnimation on opacity {
                        id: fadeOut
                        running: false
                        from: 1; to: 0
                        duration: 1500
                        easing.type: Easing.InQuad
                    }
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

            // Error overlay
            ScrollView {
                anchors.fill: parent
                visible: errorText.visible

                SText {
                    id: errorText
                    visible: false
                    width: appContainer.width - STheme.spacingMd * 2
                    x: STheme.spacingMd
                    y: STheme.spacingMd
                    color: STheme.error
                    variant: "caption"
                    wrapMode: Text.Wrap
                    font.family: "monospace"
                }
            }
        }
    }
}
