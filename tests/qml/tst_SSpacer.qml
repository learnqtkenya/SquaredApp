import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SSpacer"
    when: windowShown

    SSpacer { id: spacer }
    SSpacer { id: spacerCustom; size: 48 }

    function test_instantiation() {
        verify(spacer !== null)
    }

    function test_defaultSize() {
        compare(spacer.size, STheme.spacingMd)
        compare(spacer.implicitHeight, STheme.spacingMd)
    }

    function test_customSize() {
        compare(spacerCustom.size, 48)
        compare(spacerCustom.implicitHeight, 48)
    }
}
