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

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: appListPage
    }

    Component {
        id: appListPage

        SPage {
            title: "Squared"

            SText {
                text: "Your Apps"
                variant: "caption"
                color: STheme.textSecondary
            }

            SGrid {
                Layout.fillWidth: true
                minColumnWidth: 160

                Repeater {
                    model: ListModel {
                        ListElement {
                            appName: "Hello World"
                            appDir: "hello-world"
                            appDesc: "A starter app"
                            appIcon: "\ue9b2"
                            appColor: "#6366F1"
                        }
                        ListElement {
                            appName: "Counter"
                            appDir: "counter"
                            appDesc: "Persistent counter"
                            appIcon: "\uead0"
                            appColor: "#2196F3"
                        }
                        ListElement {
                            appName: "Todo"
                            appDir: "todo"
                            appDesc: "Task manager"
                            appIcon: "\ue614"
                            appColor: "#FF9800"
                        }
                        ListElement {
                            appName: "Finance"
                            appDir: "finance"
                            appDesc: "Track finances"
                            appIcon: "\ue850"
                            appColor: "#22C55E"
                        }
                    }

                    delegate: Item {
                        id: cardDelegate
                        required property string appName
                        required property string appDir
                        required property string appDesc
                        required property string appIcon
                        required property string appColor

                        Layout.fillWidth: true
                        Layout.preferredHeight: 160

                        SCard {
                            anchors.fill: parent

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: STheme.spacingSm

                                Item { Layout.fillHeight: true }

                                Rectangle {
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 48
                                    Layout.alignment: Qt.AlignHCenter
                                    radius: STheme.radiusMedium
                                    color: cardDelegate.appColor
                                    opacity: 0.12

                                    SIcon {
                                        anchors.centerIn: parent
                                        icon: cardDelegate.appIcon
                                        size: 28
                                        color: cardDelegate.appColor
                                    }
                                }

                                SText {
                                    text: cardDelegate.appName
                                    variant: "subheading"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                SText {
                                    text: cardDelegate.appDesc
                                    variant: "caption"
                                    color: STheme.textSecondary
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                stackView.push(appShellComponent,
                                    { appDirName: cardDelegate.appDir, appTitle: cardDelegate.appName })
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    Component {
        id: appShellComponent
        AppShell {}
    }
}
