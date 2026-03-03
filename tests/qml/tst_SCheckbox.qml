import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SCheckbox"
    when: windowShown
    width: 400
    height: 400

    SCheckbox { id: cb; text: "Accept terms"; x: 0; y: 0 }

    SignalSpy { id: toggleSpy; target: cb; signalName: "toggled" }

    function test_instantiation() {
        verify(cb !== null)
    }

    function test_defaultUnchecked() {
        compare(cb.checked, false)
    }

    function test_checkedProperty() {
        cb.checked = true
        compare(cb.checked, true)
        cb.checked = false
    }

    function test_textProperty() {
        compare(cb.text, "Accept terms")
    }

    function test_toggleSignalEmits() {
        cb.checked = false
        toggleSpy.clear()
        cb.checked = !cb.checked
        cb.toggled()
        compare(toggleSpy.count, 1)
        compare(cb.checked, true)
        cb.checked = false
    }

    function test_disabledOpacity() {
        cb.enabled = false
        compare(cb.opacity, 0.5)
        cb.enabled = true
    }
}
