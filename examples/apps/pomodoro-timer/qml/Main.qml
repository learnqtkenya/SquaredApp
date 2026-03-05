import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: ""

    property int workMinutes: Storage.get("workMinutes", 25)
    property int breakMinutes: Storage.get("breakMinutes", 5)
    property int secondsLeft: workMinutes * 60
    property bool running: false
    property bool isBreak: false
    property int sessionsCompleted: Storage.get("sessions", 0)

    function totalSeconds() { return (isBreak ? breakMinutes : workMinutes) * 60 }
    function progress() { return 1.0 - secondsLeft / totalSeconds() }

    function formatTime(secs) {
        var m = Math.floor(secs / 60)
        var s = secs % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }

    function startTimer() { root.running = true }
    function pauseTimer() { root.running = false }

    function resetTimer() {
        root.running = false
        root.secondsLeft = totalSeconds()
    }

    function skipToNext() {
        root.running = false
        if (!root.isBreak) {
            root.sessionsCompleted++
            Storage.set("sessions", root.sessionsCompleted)
        }
        root.isBreak = !root.isBreak
        root.secondsLeft = totalSeconds()
    }

    Timer {
        id: countdown
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            if (root.secondsLeft > 0) {
                root.secondsLeft--
            } else {
                root.skipToNext()
            }
        }
    }

    onWorkMinutesChanged: {
        if (!running && !isBreak) secondsLeft = workMinutes * 60
        Storage.set("workMinutes", workMinutes)
    }
    onBreakMinutesChanged: {
        if (!running && isBreak) secondsLeft = breakMinutes * 60
        Storage.set("breakMinutes", breakMinutes)
    }

    Item { Layout.fillHeight: true }

    // Status badge
    SCard {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        ColumnLayout {
            Layout.fillWidth: true
            spacing: STheme.spacingMd

            SBadge {
                Layout.alignment: Qt.AlignHCenter
                text: root.isBreak ? "Break" : "Focus"
                badgeColor: root.isBreak ? STheme.success : STheme.primary
            }

            SText {
                text: formatTime(root.secondsLeft)
                font.pixelSize: 72
                font.weight: Font.DemiBold
                color: STheme.text
                Layout.alignment: Qt.AlignHCenter
            }

            SProgressBar {
                Layout.fillWidth: true
                value: progress()
            }
        }
    }

    // Controls
    RowLayout {
        Layout.fillWidth: true
        spacing: STheme.spacingSm

        SButton {
            Layout.fillWidth: true
            text: root.running ? "Pause" : "Start"
            iconSource: root.running ? IconCodes.pause : IconCodes.playArrow
            style: "Primary"
            onClicked: root.running ? pauseTimer() : startTimer()
        }

        SButton {
            text: "Reset"
            iconSource: IconCodes.refresh
            style: "Secondary"
            onClicked: resetTimer()
        }

        SButton {
            text: "Skip"
            iconSource: IconCodes.skipNext
            style: "Ghost"
            onClicked: skipToNext()
        }
    }

    // Settings
    SCard {
        Layout.fillWidth: true

        SText { text: "Settings"; variant: "subheading" }

        RowLayout {
            Layout.fillWidth: true
            SText { text: "Work"; Layout.minimumWidth: 50 }
            SSlider {
                Layout.fillWidth: true
                from: 5; to: 60; stepSize: 5
                value: root.workMinutes
                onMoved: root.workMinutes = value
            }
            SText { text: Math.round(root.workMinutes) + "m"; variant: "caption"; Layout.minimumWidth: 35 }
        }

        RowLayout {
            Layout.fillWidth: true
            SText { text: "Break"; Layout.minimumWidth: 50 }
            SSlider {
                Layout.fillWidth: true
                from: 1; to: 30; stepSize: 1
                value: root.breakMinutes
                onMoved: root.breakMinutes = value
            }
            SText { text: Math.round(root.breakMinutes) + "m"; variant: "caption"; Layout.minimumWidth: 35 }
        }
    }

    // Stats
    SCard {
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true

            SMetric {
                Layout.fillWidth: true
                value: root.sessionsCompleted
                label: "Sessions"
                icon: IconCodes.checkCircle
            }

            SMetric {
                Layout.fillWidth: true
                value: Math.round(root.sessionsCompleted * root.workMinutes) + "m"
                label: "Focus Time"
                icon: IconCodes.timer
            }
        }
    }

    Item { Layout.fillHeight: true }
}
