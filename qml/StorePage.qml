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
    property var downloadingApps: ({})
    property string uninstallTargetId: ""
    property string uninstallTargetName: ""
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

    function requestUninstall(appId, appName) {
        storePage.uninstallTargetId = appId
        storePage.uninstallTargetName = appName
        uninstallDialog.open()
    }

    function performUninstall() {
        var appId = storePage.uninstallTargetId
        if (appId === "") return
        if (appInstaller) appInstaller.uninstall(appId, installDir, storageRoot)
        if (appRegistry) appRegistry.removeApp(appId)
        catalogList.model = storePage.filteredEntries()
        storePage.uninstallTargetId = ""
        storePage.uninstallTargetName = ""
    }

    Connections {
        target: packageDownloader
        function onInstalled(appId) {
            var d = storePage.downloadingApps
            delete d[appId]
            storePage.downloadingApps = d
            catalogList.model = storePage.filteredEntries()
        }
        function onError(appId, message) {
            var d = storePage.downloadingApps
            delete d[appId]
            storePage.downloadingApps = d
            console.warn("Install failed for", appId, ":", message)
        }
    }

    Component.onCompleted: {
        _stack = storePage.StackView.view
        if (appCatalog)
            appCatalog.fetch()
    }

    SDialog {
        id: uninstallDialog
        title: "Uninstall " + storePage.uninstallTargetName + "?"
        onAccepted: storePage.performUninstall()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingSm
            Layout.rightMargin: STheme.spacingMd
            Layout.topMargin: STheme.spacingSm
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

        // Search
        SSearchField {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd
            Layout.topMargin: STheme.spacingSm
            placeholderText: "Search store..."
            onTextChanged: storePage.searchText = text
        }

        // Category pills
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.leftMargin: STheme.spacingMd
            Layout.topMargin: STheme.spacingSm
            contentWidth: categoryRow.implicitWidth
            contentHeight: 28
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Row {
                id: categoryRow
                spacing: STheme.spacingXs

                Repeater {
                    model: storePage.categories

                    Rectangle {
                        required property string modelData
                        width: pillText.implicitWidth + STheme.spacingMd * 2
                        height: 28
                        radius: 14
                        color: storePage.selectedCategory === modelData
                               ? STheme.primary : "transparent"
                        border.width: 1
                        border.color: storePage.selectedCategory === modelData
                                      ? STheme.primary : STheme.border

                        SText {
                            id: pillText
                            anchors.centerIn: parent
                            text: modelData
                            variant: "caption"
                            color: storePage.selectedCategory === modelData
                                   ? "#FFFFFF" : STheme.textSecondary
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

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: STheme.spacingSm
            implicitHeight: 1
            color: STheme.border
        }

        // Loading
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

        // Error
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

        // Empty
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

        // Compact list
        ListView {
            id: catalogList
            visible: appCatalog ? (appCatalog.entries.length > 0 && !appCatalog.loading) : false
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: storePage.filteredEntries()

            delegate: Item {
                id: listDelegate
                required property var modelData

                width: ListView.view.width
                height: 60

                readonly property bool isInstalled: appRegistry && appRegistry.isInstalled(listDelegate.modelData.id)
                readonly property bool isDownloading: !!storePage.downloadingApps[listDelegate.modelData.id]
                readonly property string appColor: (listDelegate.modelData.color || "") !== "" ? listDelegate.modelData.color : STheme.primary
                readonly property string appIcon: (listDelegate.modelData.icon || "") !== "" ? listDelegate.modelData.icon : IconCodes.apps

                function startInstall() {
                    var d = storePage.downloadingApps
                    d[listDelegate.modelData.id] = true
                    storePage.downloadingApps = d
                    storePage.installRequested(listDelegate.modelData.id, listDelegate.modelData.packageUrl)
                }

                function startUninstall() {
                    storePage.requestUninstall(
                        listDelegate.modelData.id,
                        listDelegate.modelData.name || listDelegate.modelData.id)
                }

                // Row-level tap target (behind everything)
                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    cursorShape: listDelegate.isInstalled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (listDelegate.isInstalled)
                            listDelegate.startUninstall()
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: rowMouse.pressed ? STheme.surfaceVariant : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: STheme.spacingMd
                    anchors.rightMargin: STheme.spacingMd
                    spacing: STheme.spacingSm

                    // App icon
                    Item {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        Rectangle {
                            anchors.fill: parent
                            radius: STheme.radiusMedium
                            color: listDelegate.appColor
                            opacity: 0.12
                        }

                        SIcon {
                            anchors.centerIn: parent
                            icon: listDelegate.appIcon
                            size: 22
                            color: listDelegate.appColor
                        }
                    }

                    // Name + description
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        SText {
                            text: listDelegate.modelData.name || ""
                            variant: "body"
                            font.weight: Font.DemiBold
                            color: STheme.text
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        SText {
                            text: listDelegate.modelData.description || listDelegate.modelData.author || ""
                            variant: "caption"
                            color: STheme.textSecondary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    // Action: Get / Installing / Installed
                    Rectangle {
                        visible: !listDelegate.isInstalled && !listDelegate.isDownloading
                        Layout.preferredWidth: getLabel.implicitWidth + 24
                        Layout.preferredHeight: 28
                        radius: 14
                        color: STheme.primary

                        SText {
                            id: getLabel
                            anchors.centerIn: parent
                            text: "Get"
                            variant: "caption"
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: listDelegate.startInstall()
                        }
                    }

                    SLoadingSpinner {
                        visible: listDelegate.isDownloading
                        size: 22
                    }

                    SIcon {
                        visible: listDelegate.isInstalled && !listDelegate.isDownloading
                        icon: IconCodes.checkCircle
                        size: 22
                        color: STheme.textSecondary
                    }
                }

                // Bottom separator (indented past icon)
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: STheme.spacingMd + 40 + STheme.spacingSm
                    height: 1
                    color: STheme.border
                    opacity: 0.5
                }
            }
        }
    }
}
