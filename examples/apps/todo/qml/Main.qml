import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: todoPage
    title: ""

    property var todos: {
        var raw = Storage.get("todos", [])
        if (raw && typeof raw.length === "number") {
            var arr = []
            for (var i = 0; i < raw.length; i++) arr.push(raw[i])
            return arr
        }
        return []
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: STheme.spacingSm

        STextField {
            id: input
            Layout.fillWidth: true
            placeholderText: "What needs to be done?"
            onAccepted: todoPage.addTodo()
        }

        SButton {
            text: "Add"
            iconSource: IconCodes.add
            style: "Primary"
            onClicked: todoPage.addTodo()
        }
    }

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentHeight: scrollContent.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: scrollContent
            width: parent.width
            spacing: STheme.spacingMd

            SCard {
                visible: todoPage.todos.length > 0
                Layout.fillWidth: true

                SText {
                    text: todoPage.todos.length + " item" + (todoPage.todos.length !== 1 ? "s" : "")
                    variant: "caption"
                    color: STheme.textSecondary
                }

                SDivider {}

                Repeater {
                    model: todoPage.todos

                    SListItem {
                        required property var modelData
                        required property int index

                        title: modelData.text || ""
                        icon: modelData.done ? IconCodes.checkCircle : IconCodes.empty
                        onClicked: () => {
                            todoPage.toggleTodo(index)
                        }
                        trailing: Component {
                            SButton {
                                text: "Remove"
                                style: "Danger"
                                onClicked: todoPage.removeTodo(index)
                            }
                        }
                    }
                }
            }

            SEmptyState {
                visible: todoPage.todos.length === 0
                Layout.fillWidth: true
                title: "No todos yet"
                description: "Type above and tap Add to create one"
                icon: IconCodes.empty
            }
        }
    }

    function toggleTodo(idx) {
        var updated = todoPage.todos.slice()
        updated[idx] = { text: updated[idx].text, done: !updated[idx].done }
        todoPage.todos = updated
        Storage.set("todos", updated)
    }

    function addTodo() {
        if (input.text.trim() === "")
            return
        var updated = todoPage.todos.concat([{ text: input.text, done: false }])
        todoPage.todos = updated
        Storage.set("todos", updated)
        input.text = ""
    }

    function removeTodo(idx) {
        var updated = todoPage.todos.slice()
        updated.splice(idx, 1)
        todoPage.todos = updated
        Storage.set("todos", updated)
    }
}
