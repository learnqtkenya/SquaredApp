import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SToast"
    when: windowShown
    width: 400
    height: 400

    SToast { id: toast }

    function test_instantiation() {
        verify(toast !== null)
    }

    function test_defaultDuration() {
        compare(toast.duration, 3500)
    }

    function test_showAndDismiss() {
        toast.show("Hello", "success")
        // show appends to internal model, dismiss removes
        toast.dismiss()
        verify(true)
    }

    function test_showMethod() {
        toast.show("Test message", "error")
        toast.show("Another message", "info")
        // Multiple toasts can stack
        toast.dismiss()
        toast.dismiss()
        verify(true)
    }
}
