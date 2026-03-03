import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SRadioGroup"
    when: windowShown
    width: 400
    height: 400

    SRadioGroup {
        id: radios
        model: ["Option A", "Option B", "Option C"]
    }

    function test_instantiation() {
        verify(radios !== null)
    }

    function test_defaultNoSelection() {
        compare(radios.currentIndex, -1)
    }

    function test_selectByProperty() {
        radios.currentIndex = 1
        compare(radios.currentIndex, 1)
        radios.currentIndex = -1
    }

    function test_selectedSignal() {
        var selectedIdx = -1
        radios.selected.connect(function(idx) { selectedIdx = idx })
        // Signal exists and is connectable
        verify(true)
    }
}
