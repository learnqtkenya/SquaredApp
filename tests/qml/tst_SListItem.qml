import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SListItem"
    when: windowShown
    width: 400
    height: 400

    SListItem {
        id: item
        title: "Title"
        subtitle: "Subtitle"
        icon: IconCodes.home
        width: 400
        x: 0; y: 0
    }

    SignalSpy { id: clickSpy; target: item; signalName: "clicked" }

    function test_instantiation() {
        verify(item !== null)
    }

    function test_titleProperty() {
        compare(item.title, "Title")
    }

    function test_subtitleProperty() {
        compare(item.subtitle, "Subtitle")
    }

    function test_clickSignal() {
        clickSpy.clear()
        item.clicked()
        compare(clickSpy.count, 1)
    }

    function test_minHeight() {
        verify(item.implicitHeight >= 56)
    }
}
