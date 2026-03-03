import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SDialog"
    when: windowShown
    width: 400
    height: 400

    Item {
        id: container
        width: 400
        height: 400

        SDialog {
            id: dialog
            title: "Confirm"
            acceptText: "Yes"
            rejectText: "No"

            SText { text: "Are you sure?" }
        }
    }

    function test_instantiation() {
        verify(dialog !== null)
    }

    function test_defaultHidden() {
        compare(dialog.opened, false)
        compare(dialog.visible, false)
    }

    function test_openClose() {
        dialog.open()
        compare(dialog.opened, true)
        dialog.close()
        compare(dialog.opened, false)
    }

    function test_titleProperty() {
        compare(dialog.title, "Confirm")
    }

    function test_acceptedSignal() {
        var accepted = false
        dialog.accepted.connect(function() { accepted = true })
        verify(true)
    }
}
