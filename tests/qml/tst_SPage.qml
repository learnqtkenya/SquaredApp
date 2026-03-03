import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SPage"
    when: windowShown
    width: 400
    height: 400

    SPage {
        id: page
        title: "Test Page"
        anchors.fill: parent
    }

    function test_instantiation() {
        verify(page !== null)
    }

    function test_titleProperty() {
        compare(page.title, "Test Page")
    }

    function test_backgroundColor() {
        compare(page.color, STheme.background)
    }
}
