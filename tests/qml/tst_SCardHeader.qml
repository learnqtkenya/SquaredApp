import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SCardHeader"
    when: windowShown

    SCardHeader { id: header; title: "Title"; subtitle: "Subtitle" }
    SCardHeader { id: headerNoSub; title: "Only Title" }

    function test_instantiation() {
        verify(header !== null)
    }

    function test_titleProperty() {
        compare(header.title, "Title")
    }

    function test_subtitleProperty() {
        compare(header.subtitle, "Subtitle")
    }

    function test_emptySubtitle() {
        compare(headerNoSub.subtitle, "")
    }
}
