pragma Singleton
import QtQuick

QtObject {
    // Set these from the host ApplicationWindow (e.g., SSize.windowWidth = Qt.binding(() => window.width))
    property int windowWidth: 400
    property int windowHeight: 700

    // Breakpoints
    readonly property int compact: 600
    readonly property int medium: 840
    readonly property int expanded: 1200

    // Current size class: "compact", "medium", or "expanded"
    readonly property string sizeClass: windowWidth >= expanded ? "expanded"
                                      : windowWidth >= medium ? "medium"
                                      : "compact"

    readonly property bool isCompact: sizeClass === "compact"
    readonly property bool isMedium: sizeClass === "medium"
    readonly property bool isExpanded: sizeClass === "expanded"

    // Responsive grid columns based on window width
    readonly property int gridColumns: {
        if (windowWidth >= expanded) return Math.floor(windowWidth / 96)
        if (windowWidth >= medium) return 6
        return 4
    }

    // Content max width — caps layout width on ultra-wide screens
    readonly property int contentMaxWidth: 1200

    // Recommended margins based on size class
    readonly property int margins: isExpanded ? 32 : isMedium ? 24 : 16
}
