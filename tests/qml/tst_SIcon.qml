import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SIcon"
    when: windowShown

    SIcon { id: icon; icon: IconCodes.home }
    SIcon { id: iconSized; icon: IconCodes.search; size: 48 }

    function test_instantiation() {
        verify(icon !== null)
    }

    function test_defaultSize() {
        compare(icon.size, 24)
        compare(icon.width, 24)
        compare(icon.height, 24)
    }

    function test_customSize() {
        compare(iconSized.size, 48)
        compare(iconSized.width, 48)
    }

    function test_defaultColor() {
        compare(icon.color, STheme.text)
    }

    function test_iconProperty() {
        compare(icon.icon, IconCodes.home)
    }
}
