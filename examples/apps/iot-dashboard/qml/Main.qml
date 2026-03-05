import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: ""

    property bool autoRefresh: Storage.get("autoRefresh", true)
    property double temperature: 22.5
    property double humidity: 65
    property double pressure: 1013.2
    property double lightLevel: 750
    property bool motionDetected: false
    property double batteryLevel: 87
    property int doorOpen: 0 // 0=closed, 1=open
    property int updateCount: 0

    function randomInRange(min, max) {
        return min + Math.random() * (max - min)
    }

    function refreshSensors() {
        temperature = Math.round(randomInRange(18, 32) * 10) / 10
        humidity = Math.round(randomInRange(30, 90))
        pressure = Math.round(randomInRange(990, 1040) * 10) / 10
        lightLevel = Math.round(randomInRange(0, 1200))
        motionDetected = Math.random() > 0.7
        batteryLevel = Math.max(0, Math.round(batteryLevel - randomInRange(0, 0.5) * 10) / 10)
        doorOpen = Math.random() > 0.8 ? 1 : 0
        updateCount++
    }

    Timer {
        interval: 3000
        repeat: true
        running: root.autoRefresh
        onTriggered: refreshSensors()
    }

    Component.onCompleted: refreshSensors()

    // Header controls
    RowLayout {
        Layout.fillWidth: true

        SText { text: "Sensor Dashboard"; variant: "heading" }

        Item { Layout.fillWidth: true }

        SSwitch {
            text: "Auto"
            checked: root.autoRefresh
            onToggled: {
                root.autoRefresh = checked
                Storage.set("autoRefresh", checked)
            }
        }
    }

    // Status bar
    SCard {
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true

            SBadge {
                text: root.autoRefresh ? "Live" : "Paused"
                badgeColor: root.autoRefresh ? STheme.success : STheme.textSecondary
            }

            SText {
                text: "Updates: " + root.updateCount
                variant: "caption"
                color: STheme.textSecondary
            }

            Item { Layout.fillWidth: true }

            SButton {
                text: "Refresh"
                iconSource: IconCodes.refresh
                style: "Ghost"
                onClicked: refreshSensors()
            }
        }
    }

    // Sensor grid
    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentHeight: sensorGrid.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        SGrid {
            id: sensorGrid
            width: parent.width
            minColumnWidth: 150

            SCard {
                Layout.fillWidth: true
                SMetric {
                    Layout.fillWidth: true
                    icon: IconCodes.thermostat
                    value: root.temperature + "\u00B0C"
                    label: "Temperature"
                }
            }

            SCard {
                Layout.fillWidth: true
                SMetric {
                    Layout.fillWidth: true
                    icon: IconCodes.waterDrop
                    value: root.humidity + "%"
                    label: "Humidity"
                }
            }

            SCard {
                Layout.fillWidth: true
                SMetric {
                    Layout.fillWidth: true
                    icon: IconCodes.speed
                    value: root.pressure + " hPa"
                    label: "Pressure"
                }
            }

            SCard {
                Layout.fillWidth: true
                SMetric {
                    Layout.fillWidth: true
                    icon: IconCodes.lightMode
                    value: root.lightLevel + " lx"
                    label: "Light"
                }
            }

            SCard {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    SIcon {
                        icon: IconCodes.sensors
                        size: 28
                        color: root.motionDetected ? STheme.error : STheme.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SBadge {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.motionDetected ? "Motion" : "Clear"
                        badgeColor: root.motionDetected ? STheme.error : STheme.success
                    }

                    SText {
                        text: "Motion Sensor"
                        variant: "caption"
                        color: STheme.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            SCard {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    SIcon {
                        icon: IconCodes.battery
                        size: 28
                        color: root.batteryLevel < 20 ? STheme.error : STheme.primary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SText {
                        text: root.batteryLevel + "%"
                        variant: "heading"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SProgressBar {
                        Layout.fillWidth: true
                        value: root.batteryLevel / 100
                    }

                    SText {
                        text: "Battery"
                        variant: "caption"
                        color: STheme.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            SCard {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    SIcon {
                        icon: root.doorOpen ? IconCodes.lockOpen : IconCodes.lock
                        size: 28
                        color: root.doorOpen ? STheme.error : STheme.success
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SBadge {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.doorOpen ? "Open" : "Closed"
                        badgeColor: root.doorOpen ? STheme.error : STheme.success
                    }

                    SText {
                        text: "Door Sensor"
                        variant: "caption"
                        color: STheme.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
