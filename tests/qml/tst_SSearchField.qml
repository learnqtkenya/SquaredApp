import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SSearchField"
    when: windowShown
    width: 400
    height: 400

    SSearchField { id: field }

    function test_instantiation() {
        verify(field !== null)
    }

    function test_defaultPlaceholder() {
        compare(field.placeholderText, "Search...")
    }

    function test_textInput() {
        field.forceActiveFocus()
        field.text = ""
        field.text = "query"
        compare(field.text, "query")
        field.text = ""
    }

    function test_height() {
        compare(field.implicitHeight, 44)
    }
}
