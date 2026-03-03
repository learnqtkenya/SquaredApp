import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SSection"
    when: windowShown
    width: 400
    height: 400

    SSection {
        id: section
        title: "Settings"
        width: 400

        SText { text: "Content" }
    }

    function test_instantiation() {
        verify(section !== null)
    }

    function test_titleProperty() {
        compare(section.title, "Settings")
    }

    function test_showDividerDefault() {
        compare(section.showDivider, true)
    }
}
