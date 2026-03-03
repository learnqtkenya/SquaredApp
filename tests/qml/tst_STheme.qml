import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "STheme"
    when: windowShown

    function test_colorsExist() {
        verify(STheme.primary !== undefined)
        verify(STheme.primaryVariant !== undefined)
        verify(STheme.surface !== undefined)
        verify(STheme.surfaceVariant !== undefined)
        verify(STheme.background !== undefined)
        verify(STheme.text !== undefined)
        verify(STheme.textSecondary !== undefined)
        verify(STheme.border !== undefined)
        verify(STheme.error !== undefined)
        verify(STheme.success !== undefined)
    }

    function test_spacingValues() {
        compare(STheme.spacingXs, 4)
        compare(STheme.spacingSm, 8)
        compare(STheme.spacingMd, 16)
        compare(STheme.spacingLg, 24)
        compare(STheme.spacingXl, 32)
    }

    function test_radiiValues() {
        compare(STheme.radiusSmall, 6)
        compare(STheme.radiusMedium, 10)
        compare(STheme.radiusLarge, 16)
    }

    function test_fontsExist() {
        verify(STheme.heading !== undefined)
        verify(STheme.subheading !== undefined)
        verify(STheme.body !== undefined)
        verify(STheme.caption !== undefined)
    }

    function test_fontSizes() {
        compare(STheme.heading.pixelSize, 24)
        compare(STheme.subheading.pixelSize, 18)
        compare(STheme.body.pixelSize, 14)
        compare(STheme.caption.pixelSize, 12)
    }
}
