import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "STextField"
    when: windowShown
    width: 400
    height: 400

    STextField { id: field; placeholderText: "Enter text" }

    function test_instantiation() {
        verify(field !== null)
    }

    function test_placeholderText() {
        compare(field.placeholderText, "Enter text")
    }

    function test_textInput() {
        field.forceActiveFocus()
        field.text = ""
        keyClick(Qt.Key_H)
        keyClick(Qt.Key_I)
        compare(field.text, "hi")
        field.text = ""
    }

    function test_defaultEmpty() {
        field.text = ""
        compare(field.text, "")
    }

    function test_height() {
        compare(field.implicitHeight, 44)
    }
}
