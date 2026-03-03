import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SSlider"
    when: windowShown
    width: 400
    height: 400

    SSlider { id: slider; from: 0; to: 100; value: 50 }

    function test_instantiation() {
        verify(slider !== null)
    }

    function test_valueProperty() {
        compare(slider.value, 50)
    }

    function test_rangeProperties() {
        compare(slider.from, 0)
        compare(slider.to, 100)
    }

    function test_valueChange() {
        slider.value = 75
        compare(slider.value, 75)
        slider.value = 50
    }
}
