import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SSize"
    when: windowShown

    function test_propertiesExist() {
        verify(SSize.windowWidth !== undefined)
        verify(SSize.windowHeight !== undefined)
        verify(SSize.sizeClass !== undefined)
        verify(SSize.gridColumns !== undefined)
        verify(SSize.contentMaxWidth !== undefined)
        verify(SSize.margins !== undefined)
    }

    function test_breakpoints() {
        compare(SSize.compact, 600)
        compare(SSize.medium, 840)
        compare(SSize.expanded, 1200)
    }

    function test_sizeClassIsValid() {
        verify(SSize.sizeClass === "compact"
            || SSize.sizeClass === "medium"
            || SSize.sizeClass === "expanded")
    }

    function test_booleanHelpers() {
        // Exactly one should be true
        var count = (SSize.isCompact ? 1 : 0)
                  + (SSize.isMedium ? 1 : 0)
                  + (SSize.isExpanded ? 1 : 0)
        compare(count, 1)
    }

    function test_gridColumnsPositive() {
        verify(SSize.gridColumns >= 4)
    }

    function test_contentMaxWidth() {
        compare(SSize.contentMaxWidth, 1200)
    }
}
