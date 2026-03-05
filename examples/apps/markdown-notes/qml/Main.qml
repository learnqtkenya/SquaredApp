import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: ""

    property var notes: {
        var raw = Storage.get("notes", [])
        if (raw && typeof raw.length === "number") {
            var arr = []
            for (var i = 0; i < raw.length; i++) arr.push(raw[i])
            return arr
        }
        return []
    }

    property int selectedIndex: -1
    property bool editing: false
    property bool _loading: false  // guard against binding loops

    function saveNotes() { Storage.set("notes", root.notes) }

    function loadEditor() {
        root._loading = true
        if (root.selectedIndex >= 0 && root.selectedIndex < root.notes.length) {
            titleField.text = root.notes[root.selectedIndex].title
            bodyArea.text = root.notes[root.selectedIndex].body
        } else {
            titleField.text = ""
            bodyArea.text = ""
        }
        root._loading = false
    }

    function createNote() {
        var note = { title: "Untitled", body: "", created: new Date().toISOString() }
        root.notes = [note].concat(root.notes)
        root.selectedIndex = 0
        root.editing = true
        loadEditor()
        saveNotes()
    }

    function deleteNote(idx) {
        var updated = root.notes.slice()
        updated.splice(idx, 1)
        root.notes = updated
        if (root.selectedIndex >= root.notes.length) root.selectedIndex = -1
        root.editing = false
        saveNotes()
    }

    function updateNote(idx, title, body) {
        var updated = root.notes.slice()
        updated[idx] = { title: title, body: body, created: updated[idx].created }
        root.notes = updated
        saveNotes()
    }

    // List view
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: !root.editing
        spacing: STheme.spacingSm

        RowLayout {
            Layout.fillWidth: true

            SText { text: root.notes.length + " note" + (root.notes.length !== 1 ? "s" : ""); variant: "subheading" }

            Item { Layout.fillWidth: true }

            SButton {
                text: "New"
                iconSource: IconCodes.add
                style: "Primary"
                onClicked: root.createNote()
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: noteList.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: noteList
                width: parent.width
                spacing: STheme.spacingXs

                Repeater {
                    model: root.notes

                    SListItem {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        title: modelData.title || "Untitled"
                        subtitle: {
                            var preview = (modelData.body || "").substring(0, 60)
                            return preview || "Empty note"
                        }
                        icon: IconCodes.description
                        onClicked: {
                            root.selectedIndex = index
                            root.editing = true
                            root.loadEditor()
                        }
                        trailing: Component {
                            SButton {
                                text: ""
                                iconSource: IconCodes.close
                                style: "Ghost"
                                onClicked: root.deleteNote(index)
                            }
                        }
                    }
                }

                SEmptyState {
                    visible: root.notes.length === 0
                    Layout.fillWidth: true
                    title: "No notes"
                    description: "Tap New to create your first note"
                    icon: IconCodes.description
                    actionText: "New Note"
                    onActionClicked: root.createNote()
                }
            }
        }
    }

    // Editor view
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.editing && root.selectedIndex >= 0 && root.selectedIndex < root.notes.length
        spacing: STheme.spacingSm

        RowLayout {
            Layout.fillWidth: true

            SButton {
                text: "Back"
                iconSource: IconCodes.arrowBack
                style: "Ghost"
                onClicked: {
                    root.editing = false
                    root.selectedIndex = -1
                }
            }

            Item { Layout.fillWidth: true }

            SButton {
                text: "Delete"
                style: "Danger"
                onClicked: root.deleteNote(root.selectedIndex)
            }
        }

        STextField {
            id: titleField
            Layout.fillWidth: true
            placeholderText: "Note title"
            font.pixelSize: 20
            font.weight: Font.DemiBold
            onTextChanged: {
                if (!root._loading && root.selectedIndex >= 0 && root.selectedIndex < root.notes.length)
                    root.updateNote(root.selectedIndex, text, bodyArea.text)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: STheme.radiusMedium
            color: STheme.surface
            border.width: bodyArea.activeFocus ? 2 : 1
            border.color: bodyArea.activeFocus ? STheme.primary : STheme.border

            Flickable {
                id: bodyFlick
                anchors.fill: parent
                anchors.margins: STheme.spacingSm
                contentHeight: bodyArea.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                TextEdit {
                    id: bodyArea
                    width: bodyFlick.width
                    wrapMode: TextEdit.Wrap
                    font: STheme.body
                    color: STheme.text
                    onTextChanged: {
                        if (!root._loading && root.selectedIndex >= 0 && root.selectedIndex < root.notes.length)
                            root.updateNote(root.selectedIndex, titleField.text, text)
                    }
                }
            }
        }
    }
}
