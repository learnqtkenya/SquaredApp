import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SText"
    when: windowShown

    SText { id: defaultText; text: "Hello" }
    SText { id: headingText; text: "Title"; variant: "heading" }
    SText { id: captionText; text: "Note"; variant: "caption" }

    function test_instantiation() {
        verify(defaultText !== null)
    }

    function test_defaultVariant() {
        compare(defaultText.variant, "body")
    }

    function test_textProperty() {
        compare(defaultText.text, "Hello")
        defaultText.text = "Changed"
        compare(defaultText.text, "Changed")
        defaultText.text = "Hello"
    }

    function test_headingFont() {
        compare(headingText.font.pixelSize, STheme.heading.pixelSize)
    }

    function test_captionFont() {
        compare(captionText.font.pixelSize, STheme.caption.pixelSize)
    }

    function test_defaultColor() {
        compare(defaultText.color, STheme.text)
    }
}
