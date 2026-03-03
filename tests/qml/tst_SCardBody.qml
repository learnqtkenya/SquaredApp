import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SCardBody"
    when: windowShown

    SCardBody {
        id: body
        SText { text: "Inside body" }
    }

    function test_instantiation() {
        verify(body !== null)
    }

    function test_spacing() {
        compare(body.spacing, STheme.spacingSm)
    }
}
