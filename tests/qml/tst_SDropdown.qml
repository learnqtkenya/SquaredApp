import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SDropdown"
    when: windowShown
    width: 400
    height: 400

    SDropdown {
        id: dropdown
        model: ["Apple", "Banana", "Cherry"]
    }

    function test_instantiation() {
        verify(dropdown !== null)
    }

    function test_model() {
        compare(dropdown.model.length, 3)
    }

    function test_selectionChange() {
        dropdown.currentIndex = 1
        compare(dropdown.currentText, "Banana")
    }

    function test_height() {
        compare(dropdown.implicitHeight, 44)
    }
}
