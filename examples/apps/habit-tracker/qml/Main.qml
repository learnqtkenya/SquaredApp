import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: ""

    property var habits: {
        var raw = Storage.get("habits", [])
        if (raw && typeof raw.length === "number") {
            var arr = []
            for (var i = 0; i < raw.length; i++) arr.push(raw[i])
            return arr
        }
        return []
    }

    function today() {
        return new Date().toISOString().slice(0, 10)
    }

    function saveHabits() {
        Storage.set("habits", root.habits)
    }

    function addHabit() {
        if (nameInput.text.trim() === "") return
        var updated = root.habits.concat([{
            name: nameInput.text.trim(),
            streak: 0,
            lastCompleted: "",
            completedToday: false
        }])
        root.habits = updated
        nameInput.text = ""
        saveHabits()
    }

    function toggleHabit(idx) {
        var updated = root.habits.slice()
        var h = updated[idx]
        var t = today()

        if (h.lastCompleted === t) {
            h.completedToday = false
            h.streak = Math.max(0, h.streak - 1)
            h.lastCompleted = ""
        } else {
            h.completedToday = true
            h.streak = h.streak + 1
            h.lastCompleted = t
        }
        updated[idx] = h
        root.habits = updated
        saveHabits()
    }

    function removeHabit(idx) {
        var updated = root.habits.slice()
        updated.splice(idx, 1)
        root.habits = updated
        saveHabits()
    }

    function completedCount() {
        var n = 0
        var t = today()
        for (var i = 0; i < root.habits.length; i++) {
            if (root.habits[i].lastCompleted === t) n++
        }
        return n
    }

    Component.onCompleted: {
        // Reset completedToday flags for habits not completed today
        var t = today()
        var updated = root.habits.slice()
        var changed = false
        for (var i = 0; i < updated.length; i++) {
            if (updated[i].lastCompleted !== t && updated[i].completedToday) {
                updated[i].completedToday = false
                changed = true
            }
        }
        if (changed) {
            root.habits = updated
            saveHabits()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: STheme.spacingSm

        STextField {
            id: nameInput
            Layout.fillWidth: true
            placeholderText: "New habit name"
            onAccepted: root.addHabit()
        }

        SButton {
            text: "Add"
            iconSource: IconCodes.add
            style: "Primary"
            onClicked: root.addHabit()
        }
    }

    SCard {
        Layout.fillWidth: true
        visible: root.habits.length > 0

        RowLayout {
            Layout.fillWidth: true

            SText {
                text: completedCount() + " / " + root.habits.length + " today"
                variant: "subheading"
            }

            Item { Layout.fillWidth: true }

            SBadge {
                text: completedCount() === root.habits.length && root.habits.length > 0
                      ? "All done" : "In progress"
                badgeColor: completedCount() === root.habits.length && root.habits.length > 0
                            ? STheme.success : STheme.primary
            }
        }
    }

    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentHeight: listCol.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: listCol
            width: parent.width
            spacing: STheme.spacingSm

            Repeater {
                model: root.habits

                SCard {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: STheme.spacingSm

                        SSwitch {
                            checked: modelData.lastCompleted === root.today()
                            onToggled: root.toggleHabit(index)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            SText {
                                text: modelData.name
                                color: modelData.lastCompleted === root.today()
                                       ? STheme.textSecondary : STheme.text
                                font.strikeout: modelData.lastCompleted === root.today()
                            }

                            SText {
                                text: modelData.streak + " day streak"
                                variant: "caption"
                                color: STheme.textSecondary
                            }
                        }

                        SBadge {
                            visible: modelData.streak >= 7
                            text: modelData.streak + "d"
                            badgeColor: modelData.streak >= 30 ? STheme.success
                                      : modelData.streak >= 7 ? "#F59E0B" : STheme.primary
                        }

                        SButton {
                            text: ""
                            iconSource: IconCodes.close
                            style: "Ghost"
                            onClicked: root.removeHabit(index)
                        }
                    }
                }
            }

            SEmptyState {
                visible: root.habits.length === 0
                Layout.fillWidth: true
                title: "No habits yet"
                description: "Add a habit above to start tracking"
                icon: IconCodes.checklist
            }
        }
    }
}
