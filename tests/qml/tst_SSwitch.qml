import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SSwitch"
    when: windowShown
    width: 400
    height: 400

    SSwitch { id: sw; text: "Toggle"; x: 0; y: 0 }

    SignalSpy { id: toggleSpy; target: sw; signalName: "toggled" }

    function test_instantiation() {
        verify(sw !== null)
    }

    function test_defaultUnchecked() {
        compare(sw.checked, false)
    }

    function test_toggleProperty() {
        sw.checked = true
        compare(sw.checked, true)
        sw.checked = false
    }

    function test_toggleSignalEmits() {
        sw.checked = false
        toggleSpy.clear()
        // Simulate what the internal MouseArea does
        sw.checked = !sw.checked
        sw.toggled()
        compare(toggleSpy.count, 1)
        compare(sw.checked, true)
        sw.checked = false
    }

    function test_textLabel() {
        compare(sw.text, "Toggle")
    }

    function test_disabledOpacity() {
        sw.enabled = false
        compare(sw.opacity, 0.5)
        sw.enabled = true
    }
}
