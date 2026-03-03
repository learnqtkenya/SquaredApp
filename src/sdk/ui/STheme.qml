pragma Singleton
import QtQuick

QtObject {
    // Colors
    readonly property color primary: "#6366F1"
    readonly property color primaryVariant: "#4F46E5"
    readonly property color surface: "#FFFFFF"
    readonly property color surfaceVariant: "#F8FAFC"
    readonly property color background: "#F1F5F9"
    readonly property color text: "#0F172A"
    readonly property color textSecondary: "#64748B"
    readonly property color border: "#E2E8F0"
    readonly property color error: "#EF4444"
    readonly property color success: "#22C55E"

    // Spacing (density-independent)
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 16
    readonly property int spacingLg: 24
    readonly property int spacingXl: 32

    // Border radii
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 16

    // Fonts
    readonly property font heading: Qt.font({family: "Inter", pixelSize: 24, weight: Font.DemiBold})
    readonly property font subheading: Qt.font({family: "Inter", pixelSize: 18, weight: Font.DemiBold})
    readonly property font body: Qt.font({family: "Inter", pixelSize: 14, weight: Font.Normal})
    readonly property font caption: Qt.font({family: "Inter", pixelSize: 12, weight: Font.Normal})
}
