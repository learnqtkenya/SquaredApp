import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SButton"
    when: windowShown
    width: 400
    height: 400

    SButton { id: primary; text: "Primary"; style: "Primary"; x: 10; y: 10; width: 120; height: 44 }
    SButton { id: secondary; text: "Secondary"; style: "Secondary"; x: 10; y: 60 }
    SButton { id: ghost; text: "Ghost"; style: "Ghost"; x: 10; y: 110 }
    SButton { id: danger; text: "Danger"; style: "Danger"; x: 10; y: 160 }
    SButton { id: disabled; text: "Disabled"; enabled: false; x: 10; y: 210 }

    SignalSpy { id: clickSpy; target: primary; signalName: "clicked" }

    function test_instantiation() {
        verify(primary !== null)
    }

    function test_textProperty() {
        compare(primary.text, "Primary")
    }

    function test_clickSignal() {
        // Verify signal is emittable and connectable
        clickSpy.clear()
        primary.clicked()
        compare(clickSpy.count, 1)
    }

    function test_disabledOpacity() {
        compare(disabled.opacity, 0.5)
        compare(primary.opacity, 1.0)
    }

    function test_stylesAreDifferent() {
        verify(primary.background.color !== ghost.background.color)
    }

    function test_defaultStyle() {
        compare(primary.style, "Primary")
    }
}
