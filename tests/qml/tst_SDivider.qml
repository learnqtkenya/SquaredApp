import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SDivider"
    when: windowShown

    SDivider { id: divider }

    function test_instantiation() {
        verify(divider !== null)
    }

    function test_height() {
        compare(divider.implicitHeight, 1)
    }

    function test_color() {
        compare(divider.color, STheme.border)
    }
}
