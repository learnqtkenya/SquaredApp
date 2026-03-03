import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SLoadingSpinner"
    when: windowShown

    SLoadingSpinner { id: spinner }
    SLoadingSpinner { id: spinnerCustom; size: 64; running: false }

    function test_instantiation() {
        verify(spinner !== null)
    }

    function test_defaultSize() {
        compare(spinner.size, 32)
    }

    function test_customSize() {
        compare(spinnerCustom.size, 64)
    }

    function test_defaultRunning() {
        compare(spinner.running, true)
    }

    function test_stoppedSpinner() {
        compare(spinnerCustom.running, false)
    }

    function test_defaultColor() {
        compare(spinner.color, STheme.primary)
    }
}
