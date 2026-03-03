import QtQuick
import QtTest
import Squared.UI

TestCase {
    name: "SMetric"
    when: windowShown

    SMetric { id: metric; value: 42; label: "Count" }
    SMetric { id: metricIcon; value: "99%"; label: "Uptime"; icon: IconCodes.dashboard }

    function test_instantiation() {
        verify(metric !== null)
    }

    function test_valueProperty() {
        compare(metric.value, 42)
    }

    function test_labelProperty() {
        compare(metric.label, "Count")
    }

    function test_stringValue() {
        compare(metricIcon.value, "99%")
    }

    function test_iconProperty() {
        compare(metricIcon.icon, IconCodes.dashboard)
    }
}
