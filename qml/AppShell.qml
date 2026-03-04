import QtQuick
import QtQuick.Controls
import Squared.UI

Rectangle {
    id: shell

    required property string appDirName

    property StackView _stack: null

    color: STheme.background

    Shortcut {
        sequence: "Escape"
        onActivated: {
            appRunner.close()
            if (shell._stack)
                shell._stack.pop()
        }
    }

    Item {
        id: appContainer
        anchors.fill: parent
    }

    Component.onCompleted: {
        shell._stack = shell.StackView.view
        appRunner.launchFromPath(examplesPath + "/" + shell.appDirName, appContainer)
    }
}
