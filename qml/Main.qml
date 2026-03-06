import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Squared.UI

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 700
    title: "Squared"
    color: STheme.background

    Component.onCompleted: {
        SSize.windowWidth = Qt.binding(() => window.width)
        SSize.windowHeight = Qt.binding(() => window.height)
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePage

        pushEnter: Transition {
            PropertyAnimation { property: "x"; from: stackView.width; to: 0; duration: 250; easing.type: Easing.OutCubic }
        }
        pushExit: Transition {
            PropertyAnimation { property: "x"; from: 0; to: -stackView.width * 0.3; duration: 250; easing.type: Easing.OutCubic }
        }
        popEnter: Transition {
            PropertyAnimation { property: "x"; from: -stackView.width * 0.3; to: 0; duration: 250; easing.type: Easing.OutCubic }
        }
        popExit: Transition {
            PropertyAnimation { property: "x"; from: 0; to: stackView.width; duration: 250; easing.type: Easing.OutCubic }
        }
    }

    Component {
        id: homePage

        Item {
            id: homeRoot
            property string searchText: ""

            Component {
                id: appShellComponent
                AppShell {}
            }

            Component {
                id: storePageComponent
                StorePage {
                    onInstallRequested: (appId, packageUrl) => {
                        packageDownloader.download(appId, packageUrl, installDir)
                    }
                }
            }

            function launchApp(appDir: string) {
                homeRoot.StackView.view.push(appShellComponent,
                    { appDirName: appDir })
            }

            function openStore() {
                homeRoot.StackView.view.push(storePageComponent)
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: STheme.spacingMd
                spacing: STheme.spacingSm

                // Search bar + theme toggle + store icon
                RowLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    SSearchField {
                        Layout.fillWidth: true
                        placeholderText: "Search apps..."
                        onTextChanged: homeRoot.searchText = text
                    }

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: STheme.radiusSmall
                        color: mouseTheme.pressed ? STheme.surfaceVariant : "transparent"

                        SIcon {
                            anchors.centerIn: parent
                            icon: STheme.dark ? IconCodes.lightMode : IconCodes.darkMode
                            size: 22
                            color: STheme.text
                        }

                        MouseArea {
                            id: mouseTheme
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: STheme.dark = !STheme.dark
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: STheme.radiusSmall
                        color: mouseStore.pressed ? STheme.surfaceVariant : "transparent"

                        SIcon {
                            anchors.centerIn: parent
                            icon: IconCodes.store
                            size: 22
                            color: STheme.primary
                        }

                        MouseArea {
                            id: mouseStore
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: homeRoot.openStore()
                        }
                    }
                }

                // Empty state — shown when no apps installed
                SEmptyState {
                    visible: installedAppsModel ? installedAppsModel.rowCount() === 0 : true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: IconCodes.store
                    title: "No apps installed"
                    description: "Browse the store to discover and install apps"
                    actionText: "Open Store"
                    onActionClicked: homeRoot.openStore()
                }

                // App icon grid
                GridView {
                    visible: installedAppsModel ? installedAppsModel.rowCount() > 0 : false
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: width / SSize.gridColumns
                    cellHeight: 96
                    clip: true

                    model: installedAppsModel

                    delegate: Item {
                        id: iconDelegate
                        required property string appName
                        required property string appDirName
                        required property string appIcon
                        required property string appColor

                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight
                        visible: homeRoot.searchText === ""
                                 || appName.toLowerCase().indexOf(homeRoot.searchText.toLowerCase()) >= 0

                        Column {
                            anchors.centerIn: parent
                            spacing: STheme.spacingSm

                            Item {
                                width: 48
                                height: 48
                                anchors.horizontalCenter: parent.horizontalCenter

                                Rectangle {
                                    anchors.fill: parent
                                    radius: STheme.radiusMedium
                                    color: iconDelegate.appColor
                                    opacity: 0.12
                                }

                                SIcon {
                                    anchors.centerIn: parent
                                    icon: iconDelegate.appIcon
                                    size: 28
                                    color: iconDelegate.appColor
                                }
                            }

                            SText {
                                text: iconDelegate.appName
                                variant: "caption"
                                color: STheme.text
                                elide: Text.ElideRight
                                width: 72
                                anchors.horizontalCenter: parent.horizontalCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: homeRoot.launchApp(iconDelegate.appDirName)
                        }
                    }
                }
            }
        }
    }
}
