import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Squared.UI

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 700
    title: " "
    color: "transparent"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePage
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

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: STheme.spacingMd
                spacing: STheme.spacingSm

                // Search bar + catalog icon
                RowLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Search apps..."
                        font: STheme.body
                        color: STheme.text
                        placeholderTextColor: STheme.textSecondary
                        leftPadding: 40
                        topPadding: 10
                        bottomPadding: 10

                        onTextChanged: homeRoot.searchText = text

                        background: Rectangle {
                            color: STheme.surface
                            radius: STheme.radiusLarge
                            border.color: STheme.border
                            border.width: 1

                            SIcon {
                                icon: IconCodes.search
                                size: 20
                                color: STheme.textSecondary
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                            }
                        }
                    }

                    SIcon {
                        icon: IconCodes.store
                        size: 24
                        color: STheme.primary

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: homeRoot.StackView.view.push(storePageComponent)
                        }
                    }
                }

                // App icon grid
                GridView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: width / 4
                    cellHeight: 88
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
                                color: "#FFFFFF"
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
