import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SCard"
    when: windowShown

    SCard {
        id: card
        SText { text: "Content" }
    }

    function test_instantiation() {
        verify(card !== null)
    }

    function test_surfaceColor() {
        compare(card.color, STheme.surface)
    }

    function test_radius() {
        compare(card.radius, STheme.radiusMedium)
    }

    function test_border() {
        compare(card.border.color, STheme.border)
        compare(card.border.width, 1)
    }
}
