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

            function launchApp(appDir: string) {
                homeRoot.StackView.view.push(appShellComponent,
                    { appDirName: appDir })
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: STheme.spacingMd
                spacing: STheme.spacingLg

                // Search bar
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

                // App icon grid
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: grid.implicitHeight
                    clip: true

                    GridLayout {
                        id: grid
                        width: parent.width
                        columns: 4
                        columnSpacing: STheme.spacingMd
                        rowSpacing: STheme.spacingLg

                        Repeater {
                            model: ListModel {
                                ListElement {
                                    appName: "Hello World"
                                    appDir: "hello-world"
                                    appIcon: "\ue9b2"
                                    appColor: "#6366F1"
                                }
                                ListElement {
                                    appName: "Counter"
                                    appDir: "counter"
                                    appIcon: "\uead0"
                                    appColor: "#2196F3"
                                }
                                ListElement {
                                    appName: "Todo"
                                    appDir: "todo"
                                    appIcon: "\ue614"
                                    appColor: "#FF9800"
                                }
                                ListElement {
                                    appName: "Finance"
                                    appDir: "finance"
                                    appIcon: "\ue850"
                                    appColor: "#22C55E"
                                }
                            }

                            delegate: Item {
                                id: iconDelegate
                                required property string appName
                                required property string appDir
                                required property string appIcon
                                required property string appColor

                                visible: homeRoot.searchText === ""
                                         || appName.toLowerCase().indexOf(homeRoot.searchText.toLowerCase()) >= 0
                                Layout.fillWidth: true
                                Layout.preferredHeight: visible ? 80 : 0

                                ColumnLayout {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    spacing: STheme.spacingSm

                                    Item {
                                        Layout.preferredWidth: 48
                                        Layout.preferredHeight: 48
                                        Layout.alignment: Qt.AlignHCenter

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
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.maximumWidth: 72
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: homeRoot.launchApp(iconDelegate.appDir)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: appShellComponent
        AppShell {}
    }
}
