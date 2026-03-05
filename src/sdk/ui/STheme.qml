pragma Singleton
import QtQuick
import QtCore

QtObject {
    id: root
    property bool dark: false

    property Settings _settings: Settings {
        category: "theme"
        property alias dark: root.dark
    }

    // Colors — dynamic based on dark mode
    readonly property color primary: "#6366F1"
    readonly property color primaryVariant: "#4F46E5"
    property color surface: dark ? "#1E293B" : "#FFFFFF"
    property color surfaceVariant: dark ? "#334155" : "#F8FAFC"
    property color background: dark ? "#0F172A" : "#F1F5F9"
    property color text: dark ? "#F1F5F9" : "#0F172A"
    property color textSecondary: dark ? "#94A3B8" : "#64748B"
    property color border: dark ? "#475569" : "#E2E8F0"
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
