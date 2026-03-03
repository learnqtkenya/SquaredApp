import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SBadge"
    when: windowShown

    SBadge { id: badge; text: "New" }

    function test_instantiation() {
        verify(badge !== null)
    }

    function test_text() {
        compare(badge.text, "New")
    }

    function test_defaultColor() {
        compare(badge.badgeColor, STheme.primary)
    }

    function test_pillShape() {
        compare(badge.radius, badge.height / 2)
    }
}
