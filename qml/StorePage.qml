import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Squared.UI

Rectangle {
    id: storePage
    color: STheme.background

    signal installRequested(string appId, url packageUrl)

    property var _stack: null
    property string searchText: ""
    property string selectedCategory: "All"
    readonly property var categories: ["All", "Productivity", "Utility", "Developer", "Finance", "IoT"]

    function filteredEntries() {
        var entries = appCatalog ? appCatalog.entries : []
        return entries.filter(function(e) {
            var matchSearch = storePage.searchText === ""
                || (e.name || "").toLowerCase().indexOf(storePage.searchText.toLowerCase()) >= 0
            var matchCategory = storePage.selectedCategory === "All"
                || (e.category || "") === storePage.selectedCategory
            return matchSearch && matchCategory
        })
    }

    Component.onCompleted: {
        _stack = storePage.StackView.view
        if (appCatalog)
            appCatalog.fetch()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: STheme.spacingMd
        spacing: STheme.spacingSm

        // Header with back button
        RowLayout {
            Layout.fillWidth: true
            spacing: STheme.spacingSm

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: STheme.radiusSmall
                color: mouseBack.pressed ? STheme.surfaceVariant : "transparent"

                SIcon {
                    anchors.centerIn: parent
                    icon: IconCodes.arrowBack
                    size: 22
                    color: STheme.text
                }

                MouseArea {
                    id: mouseBack
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (storePage._stack) storePage._stack.pop() }
                }
            }

            SText {
                text: "Store"
                variant: "heading"
                color: STheme.text
                Layout.fillWidth: true
            }
        }

        // Search field
        SSearchField {
            Layout.fillWidth: true
            placeholderText: "Search store..."
            onTextChanged: storePage.searchText = text
        }

        // Category pills (horizontally scrollable)
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            contentWidth: categoryRow.implicitWidth
            contentHeight: 36
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            RowLayout {
                id: categoryRow
                spacing: STheme.spacingSm

                Repeater {
                    model: storePage.categories

                    Rectangle {
                        required property string modelData
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: pillText.implicitWidth + STheme.spacingMd * 2
                        radius: STheme.radiusLarge
                        color: storePage.selectedCategory === modelData
                               ? STheme.primary : STheme.surfaceVariant
                        border.width: 1
                        border.color: storePage.selectedCategory === modelData
                                      ? STheme.primary : STheme.border

                        SText {
                            id: pillText
                            anchors.centerIn: parent
                            text: modelData
                            variant: "caption"
                            color: storePage.selectedCategory === modelData
                                   ? "#FFFFFF" : STheme.text
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: storePage.selectedCategory = modelData
                        }
                    }
                }
            }
        }

        // Loading state
        ColumnLayout {
            visible: appCatalog ? appCatalog.loading : false
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: STheme.spacingMd

            Item { Layout.fillHeight: true }

            SLoadingSpinner {
                size: 48
                Layout.alignment: Qt.AlignHCenter
            }

            SText {
                text: "Loading catalog..."
                variant: "body"
                color: STheme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }
        }

        // Error state
        SEmptyState {
            visible: appCatalog ? (appCatalog.errorMessage !== "" && !appCatalog.loading) : false
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Could not load store"
            description: appCatalog ? appCatalog.errorMessage : ""
            icon: IconCodes.warning
            actionText: "Retry"
            onActionClicked: {
                if (appCatalog)
                    appCatalog.fetch()
            }
        }

        // Empty state (no error, not loading, but no entries)
        SEmptyState {
            visible: appCatalog ? (appCatalog.entries.length === 0
                     && appCatalog.errorMessage === ""
                     && !appCatalog.loading) : false
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "No apps available"
            description: "Check back later for new apps"
            icon: IconCodes.apps
        }

        // Catalog grid
        GridView {
            id: catalogGrid
            visible: appCatalog ? (appCatalog.entries.length > 0 && !appCatalog.loading) : false
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            readonly property int cols: Math.max(2, Math.floor(width / 280))
            cellWidth: width / cols
            cellHeight: 180

            model: storePage.filteredEntries()

            delegate: Item {
                id: gridDelegate
                required property var modelData

                width: catalogGrid.cellWidth
                height: catalogGrid.cellHeight

                Item {
                    anchors.fill: parent
                    anchors.margins: STheme.spacingXs

                    SCard {
                        anchors.fill: parent

                        // Icon + badge row
                        RowLayout {
                            Layout.fillWidth: true

                            Item {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40

                                Rectangle {
                                    anchors.fill: parent
                                    radius: STheme.radiusMedium
                                    color: STheme.primary
                                    opacity: 0.12
                                }

                                SIcon {
                                    anchors.centerIn: parent
                                    icon: IconCodes.apps
                                    size: 24
                                    color: STheme.primary
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Loader {
                                sourceComponent: (appRegistry && appRegistry.isInstalled(gridDelegate.modelData.id))
                                                 ? installedBadge : installButton
                            }
                        }

                        // App name
                        SText {
                            text: gridDelegate.modelData.name || ""
                            variant: "body"
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Author
                        SText {
                            text: gridDelegate.modelData.author || ""
                            variant: "caption"
                            color: STheme.textSecondary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Description
                        SText {
                            visible: (gridDelegate.modelData.description || "") !== ""
                            text: gridDelegate.modelData.description || ""
                            variant: "caption"
                            color: STheme.textSecondary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }

                        // Permission badges
                        Flow {
                            visible: (gridDelegate.modelData.permissions || []).length > 0
                            Layout.fillWidth: true
                            spacing: STheme.spacingXs

                            Repeater {
                                model: gridDelegate.modelData.permissions || []
                                SBadge {
                                    required property string modelData
                                    text: modelData
                                    badgeColor: STheme.primaryVariant
                                    textColor: "#FFFFFF"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: installedBadge
        SBadge {
            text: "Installed"
            badgeColor: STheme.surfaceVariant
            textColor: STheme.textSecondary
        }
    }

    Component {
        id: installButton
        SButton {
            text: "Get"
            style: "Secondary"
            onClicked: {
                var entry = parent.parent.parent.parent.parent.modelData
                storePage.installRequested(entry.id, entry.packageUrl)
            }
        }
    }
}
