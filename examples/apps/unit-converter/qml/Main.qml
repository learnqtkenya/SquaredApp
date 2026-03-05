import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: ""

    property var categories: [
        {
            name: "Length",
            units: ["Meters", "Kilometers", "Feet", "Miles", "Inches", "Centimeters"],
            factors: [1, 1000, 0.3048, 1609.344, 0.0254, 0.01]
        },
        {
            name: "Weight",
            units: ["Kilograms", "Grams", "Pounds", "Ounces"],
            factors: [1, 0.001, 0.453592, 0.0283495]
        },
        {
            name: "Temperature",
            units: ["Celsius", "Fahrenheit", "Kelvin"],
            factors: []
        },
        {
            name: "Volume",
            units: ["Liters", "Milliliters", "Gallons", "Cups"],
            factors: [1, 0.001, 3.78541, 0.236588]
        }
    ]

    property int selectedCategory: Storage.get("category", 0)
    property int fromUnit: 0
    property int toUnit: 1
    property string inputValue: "1"

    function currentCategory() { return categories[selectedCategory] }

    function convert() {
        var val = parseFloat(inputValue)
        if (isNaN(val)) return ""
        var cat = currentCategory()

        if (cat.name === "Temperature") {
            return convertTemperature(val, fromUnit, toUnit).toFixed(4)
        }
        var baseVal = val * cat.factors[fromUnit]
        return (baseVal / cat.factors[toUnit]).toFixed(4)
    }

    function convertTemperature(val, from, to) {
        // Convert to Celsius first
        var celsius
        if (from === 0) celsius = val
        else if (from === 1) celsius = (val - 32) * 5 / 9
        else celsius = val - 273.15

        // Convert from Celsius to target
        if (to === 0) return celsius
        if (to === 1) return celsius * 9 / 5 + 32
        return celsius + 273.15
    }

    onSelectedCategoryChanged: {
        fromUnit = 0
        toUnit = 1
        Storage.set("category", selectedCategory)
    }

    SCard {
        Layout.fillWidth: true

        SText { text: "Category"; variant: "caption"; color: STheme.textSecondary }

        SDropdown {
            Layout.fillWidth: true
            model: categories.map(function(c) { return c.name })
            currentIndex: root.selectedCategory
            onActivated: (index) => { root.selectedCategory = index }
        }
    }

    SCard {
        Layout.fillWidth: true

        SText { text: "From"; variant: "caption"; color: STheme.textSecondary }

        SDropdown {
            Layout.fillWidth: true
            model: currentCategory().units
            currentIndex: root.fromUnit
            onActivated: (index) => { root.fromUnit = index }
        }

        STextField {
            Layout.fillWidth: true
            text: root.inputValue
            placeholderText: "Enter value"
            onTextChanged: root.inputValue = text
        }
    }

    SCard {
        Layout.fillWidth: true

        SText { text: "To"; variant: "caption"; color: STheme.textSecondary }

        SDropdown {
            Layout.fillWidth: true
            model: currentCategory().units
            currentIndex: root.toUnit
            onActivated: (index) => { root.toUnit = index }
        }
    }

    SCard {
        Layout.fillWidth: true

        SMetric {
            Layout.fillWidth: true
            value: convert()
            label: currentCategory().units[toUnit] || ""
            icon: IconCodes.swapHoriz
        }
    }

    SButton {
        Layout.fillWidth: true
        text: "Swap Units"
        iconSource: IconCodes.swapVert
        style: "Secondary"
        onClicked: {
            var tmp = root.fromUnit
            root.fromUnit = root.toUnit
            root.toUnit = tmp
        }
    }

    Item { Layout.fillHeight: true }
}
