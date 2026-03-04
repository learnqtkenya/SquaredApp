import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Squared.UI

Rectangle {
    id: shell

    required property string appDirName
    required property string appTitle

    color: STheme.background

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: STheme.spacingSm
            spacing: STheme.spacingSm

            SButton {
                text: "Back"
                iconSource: IconCodes.arrowBack
                style: "Ghost"
                onClicked: () => {
                    appRunner.close()
                    shell.StackView.view.pop()
                }
            }

            SText {
                text: shell.appTitle
                variant: "subheading"
                Layout.fillWidth: true
            }
        }

        SDivider {}

        Item {
            id: appContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        appRunner.launchFromPath(examplesPath + "/" + shell.appDirName, appContainer)
    }
}
