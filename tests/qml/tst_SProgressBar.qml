import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SProgressBar"
    when: windowShown

    SProgressBar { id: bar; value: 0.5 }
    SProgressBar { id: indeterminate; indeterminate: true }

    function test_instantiation() {
        verify(bar !== null)
    }

    function test_valueProperty() {
        compare(bar.value, 0.5)
        bar.value = 0.75
        compare(bar.value, 0.75)
        bar.value = 0.5
    }

    function test_indeterminateMode() {
        compare(indeterminate.indeterminate, true)
        compare(bar.indeterminate, false)
    }

    function test_height() {
        compare(bar.implicitHeight, 6)
    }
}
