import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: ""

    property var createdObject: null
    property string errorText: ""
    property string statusText: ""
    property string sourceCode: Storage.get("source_v3", defaultSource)

    readonly property string defaultSource:
'import QtQuick
import QtQuick.Layouts

Rectangle {
    color: "#F1F5F9"
    radius: 10

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Text {
            text: "Hello from QML!"
            font.pixelSize: 24
            font.bold: true
            color: "#0F172A"
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            width: 140; height: 44
            radius: 8
            color: tapArea.pressed ? "#4F46E5" : "#6366F1"
            Layout.alignment: Qt.AlignHCenter

            Text {
                anchors.centerIn: parent
                text: "Click me"
                color: "white"
                font.pixelSize: 14
            }

            MouseArea {
                id: tapArea
                anchors.fill: parent
                onClicked: output.text = "It works!"
            }
        }

        Text {
            id: output
            text: "Edit the code above"
            font.pixelSize: 14
            color: "#64748B"
            Layout.alignment: Qt.AlignHCenter
        }
    }
}'

    function runCode() {
        if (root.createdObject) {
            root.createdObject.destroy()
            root.createdObject = null
        }
        root.errorText = ""
        root.statusText = ""

        try {
            var obj = Qt.createQmlObject(root.sourceCode, outputContainer, "playground")
            if (obj) {
                root.createdObject = obj
                // Use explicit width/height bindings instead of anchors.fill
                obj.width = Qt.binding(function() { return outputContainer.width })
                obj.height = Qt.binding(function() { return outputContainer.height })
                Storage.set("source_v3", root.sourceCode)
                root.statusText = "Running"
            } else {
                root.errorText = "Failed to create object"
            }
        } catch (e) {
            if (e.qmlErrors) {
                var lines = []
                for (var i = 0; i < e.qmlErrors.length; i++) {
                    var err = e.qmlErrors[i]
                    lines.push("Line " + err.lineNumber + ": " + err.message)
                }
                root.errorText = lines.join("\n")
            } else {
                root.errorText = String(e)
            }
        }
    }

    function resetCode() {
        codeArea.text = defaultSource
        root.sourceCode = defaultSource
        Storage.set("source_v3", defaultSource)
        if (root.createdObject) {
            root.createdObject.destroy()
            root.createdObject = null
        }
        root.errorText = ""
        root.statusText = ""
    }

    // Editor
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 200
        radius: STheme.radiusMedium
        color: "#1E293B"
        border.width: codeArea.activeFocus ? 2 : 1
        border.color: codeArea.activeFocus ? STheme.primary : STheme.border

        Flickable {
            id: codeFlick
            anchors.fill: parent
            anchors.margins: STheme.spacingSm
            contentHeight: codeArea.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            TextEdit {
                id: codeArea
                width: codeFlick.width
                wrapMode: TextEdit.Wrap
                font.family: "monospace"
                font.pixelSize: 13
                color: "#E2E8F0"
                selectionColor: STheme.primary
                Component.onCompleted: text = root.sourceCode
                onTextChanged: root.sourceCode = text
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: STheme.spacingSm

        SButton {
            Layout.fillWidth: true
            text: "Run"
            iconSource: IconCodes.playArrow
            style: "Primary"
            onClicked: root.runCode()
        }

        SButton {
            text: "Reset"
            iconSource: IconCodes.refresh
            style: "Ghost"
            onClicked: root.resetCode()
        }
    }

    // Error display
    SCard {
        Layout.fillWidth: true
        visible: root.errorText !== ""

        SText {
            text: root.errorText
            color: STheme.error
            variant: "caption"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }

    // Status
    RowLayout {
        Layout.fillWidth: true
        visible: root.statusText !== ""

        SBadge {
            text: root.statusText
            badgeColor: STheme.success
        }
    }

    // Output area
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 200
        radius: STheme.radiusMedium
        color: STheme.surface
        border.width: 1
        border.color: STheme.border
        clip: true

        SText {
            id: outputLabel
            text: "Output"
            variant: "caption"
            color: STheme.textSecondary
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: STheme.spacingSm
        }

        Item {
            id: outputContainer
            anchors.top: outputLabel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: STheme.spacingSm

            SEmptyState {
                anchors.centerIn: parent
                visible: root.createdObject === null && root.errorText === ""
                title: "No output"
                description: "Tap Run to execute your QML"
                icon: IconCodes.code
            }
        }
    }
}
