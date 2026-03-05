import QtQuick
import QtQuick.Layouts
import Squared.UI

Rectangle {
    id: installedPage
    color: STheme.background

    signal appLaunched(string appDir)

    property string searchText: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: STheme.spacingMd
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

            onTextChanged: installedPage.searchText = text

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
                visible: installedPage.searchText === ""
                         || appName.toLowerCase().indexOf(installedPage.searchText.toLowerCase()) >= 0

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
                    onClicked: installedPage.appLaunched(iconDelegate.appDirName)
                }
            }
        }

        SEmptyState {
            visible: installedAppsModel.rowCount === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "No apps installed"
            description: "Browse the Store to find apps"
            icon: IconCodes.apps
        }
    }
}
