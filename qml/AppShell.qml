import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Squared.UI

Rectangle {
    id: shell

    required property string appDirName

    property StackView _stack: null

    color: STheme.background

    Shortcut {
        sequence: "Escape"
        onActivated: shell.closeApp()
    }

    function closeApp() {
        appRunner.close()
        if (shell._stack)
            shell._stack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Toolbar
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 48
            color: STheme.surface
            border.width: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: STheme.spacingSm
                anchors.rightMargin: STheme.spacingMd
                spacing: STheme.spacingSm

                SButton {
                    text: ""
                    iconSource: IconCodes.arrowBack
                    style: "Ghost"
                    onClicked: shell.closeApp()
                }

                SText {
                    text: shell.appDirName
                    variant: "subheading"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            // Bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: STheme.border
            }
        }

        // App container
        Item {
            id: appContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        shell._stack = shell.StackView.view
        appRunner.launchFromPath(examplesPath + "/" + shell.appDirName, appContainer)
    }
}
