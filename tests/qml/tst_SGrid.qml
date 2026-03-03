import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SGrid"
    when: windowShown
    width: 400
    height: 400

    Item {
        width: 400
        height: 400

        SGrid {
            id: grid

            Repeater {
                model: 6
                Rectangle { width: 50; height: 50; color: STheme.primary }
            }
        }
    }

    function test_instantiation() {
        verify(grid !== null)
    }

    function test_defaultSpacing() {
        compare(grid.columnSpacing, STheme.spacingMd)
        compare(grid.rowSpacing, STheme.spacingMd)
    }

    function test_columnsComputed() {
        verify(grid.columns >= 1)
    }
}
