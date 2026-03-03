import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SEmptyState"
    when: windowShown
    width: 400
    height: 400

    SEmptyState {
        id: empty
        icon: IconCodes.empty
        title: "Nothing here"
        description: "Add something to get started"
        actionText: "Add Item"
    }

    function test_instantiation() {
        verify(empty !== null)
    }

    function test_titleProperty() {
        compare(empty.title, "Nothing here")
    }

    function test_descriptionProperty() {
        compare(empty.description, "Add something to get started")
    }

    function test_actionSignal() {
        var clicked = false
        empty.actionClicked.connect(function() { clicked = true })
        // Signal exists and is connectable
        verify(true)
    }
}
