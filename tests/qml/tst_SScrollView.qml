import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SScrollView"
    when: windowShown
    width: 400
    height: 400

    SScrollView {
        id: scrollView
        width: 200
        height: 100

        Column {
            Repeater {
                model: 20
                SText { text: "Item " + index }
            }
        }
    }

    function test_instantiation() {
        verify(scrollView !== null)
    }

    function test_clipEnabled() {
        compare(scrollView.clip, true)
    }
}
