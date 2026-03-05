import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: ""

    property int red: Storage.get("red", 33)
    property int green: Storage.get("green", 150)
    property int blue: Storage.get("blue", 243)

    property var savedColors: {
        var raw = Storage.get("savedColors", [])
        if (raw && typeof raw.length === "number") {
            var arr = []
            for (var i = 0; i < raw.length; i++) arr.push(raw[i])
            return arr
        }
        return []
    }

    function currentHex() {
        return "#" + hex(red) + hex(green) + hex(blue)
    }

    function hex(v) {
        var s = Math.round(v).toString(16)
        return s.length < 2 ? "0" + s : s
    }

    function saveColor() {
        var h = currentHex()
        for (var i = 0; i < savedColors.length; i++) {
            if (savedColors[i] === h) return
        }
        var updated = [h].concat(savedColors).slice(0, 20)
        root.savedColors = updated
        Storage.set("savedColors", updated)
    }

    function removeColor(idx) {
        var updated = savedColors.slice()
        updated.splice(idx, 1)
        root.savedColors = updated
        Storage.set("savedColors", updated)
    }

    function loadColor(hex) {
        var r = parseInt(hex.substring(1, 3), 16)
        var g = parseInt(hex.substring(3, 5), 16)
        var b = parseInt(hex.substring(5, 7), 16)
        root.red = r; root.green = g; root.blue = b
        storeSliders()
    }

    function storeSliders() {
        Storage.set("red", root.red)
        Storage.set("green", root.green)
        Storage.set("blue", root.blue)
    }

    // Color preview
    Rectangle {
        Layout.fillWidth: true
        height: 120
        radius: STheme.radiusMedium
        color: currentHex()

        SText {
            anchors.centerIn: parent
            text: currentHex().toUpperCase()
            font.pixelSize: 28
            font.weight: Font.DemiBold
            color: (red * 0.299 + green * 0.587 + blue * 0.114) > 128 ? "#000000" : "#FFFFFF"
        }
    }

    // Sliders
    SCard {
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            SText { text: "R"; color: "#E53935"; font.weight: Font.DemiBold }
            SSlider {
                Layout.fillWidth: true
                from: 0; to: 255; stepSize: 1
                value: root.red
                onMoved: { root.red = value; storeSliders() }
            }
            SText { text: Math.round(root.red); variant: "caption"; Layout.minimumWidth: 30 }
        }

        RowLayout {
            Layout.fillWidth: true
            SText { text: "G"; color: "#43A047"; font.weight: Font.DemiBold }
            SSlider {
                Layout.fillWidth: true
                from: 0; to: 255; stepSize: 1
                value: root.green
                onMoved: { root.green = value; storeSliders() }
            }
            SText { text: Math.round(root.green); variant: "caption"; Layout.minimumWidth: 30 }
        }

        RowLayout {
            Layout.fillWidth: true
            SText { text: "B"; color: "#1E88E5"; font.weight: Font.DemiBold }
            SSlider {
                Layout.fillWidth: true
                from: 0; to: 255; stepSize: 1
                value: root.blue
                onMoved: { root.blue = value; storeSliders() }
            }
            SText { text: Math.round(root.blue); variant: "caption"; Layout.minimumWidth: 30 }
        }
    }

    SButton {
        Layout.fillWidth: true
        text: "Save Color"
        iconSource: IconCodes.save
        style: "Primary"
        onClicked: saveColor()
    }

    // Saved colors
    SCard {
        Layout.fillWidth: true
        visible: root.savedColors.length > 0

        SText { text: "Saved Colors"; variant: "subheading" }

        Flow {
            Layout.fillWidth: true
            spacing: STheme.spacingSm

            Repeater {
                model: root.savedColors

                Rectangle {
                    required property string modelData
                    required property int index
                    width: 44; height: 44
                    radius: STheme.radiusSmall
                    color: modelData
                    border.width: modelData === currentHex() ? 3 : 1
                    border.color: modelData === currentHex() ? STheme.primary : STheme.border

                    MouseArea {
                        anchors.fill: parent
                        onClicked: loadColor(modelData)
                        onPressAndHold: removeColor(index)
                    }
                }
            }
        }

        SText {
            text: "Tap to load, hold to remove"
            variant: "caption"
            color: STheme.textSecondary
        }
    }

    Item { Layout.fillHeight: true }
}
