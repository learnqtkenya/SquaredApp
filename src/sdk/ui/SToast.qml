pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string text: ""
    property int duration: 3500
    property string type: "info"

    function show(message: string, toastType: string) {
        listModel.append({
            alertText: message,
            alertType: toastType || "info",
            closeTime: root.duration
        })
    }

    function dismiss() {
        if (listModel.count > 0)
            listModel.remove(0)
    }

    function removeAt(idx: int) {
        if (idx >= 0 && idx < listModel.count)
            listModel.remove(idx)
    }

    anchors.fill: parent
    z: 1000

    ListView {
        id: listView
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: STheme.spacingXl
        width: Math.min(parent.width - STheme.spacingLg * 2, 400)
        height: contentHeight
        spacing: STheme.spacingSm
        interactive: false
        verticalLayoutDirection: ListView.BottomToTop

        model: ListModel {
            id: listModel
        }

        delegate: Rectangle {
            id: alertItem

            required property int index
            required property string alertText
            required property string alertType
            required property int closeTime

            width: ListView.view.width
            implicitHeight: Math.max(alertContent.implicitHeight + STheme.spacingMd * 2, 48)
            radius: STheme.radiusMedium
            color: {
                switch (alertItem.alertType) {
                case "success": return "#065F46"
                case "error": return "#991B1B"
                case "warning": return "#92400E"
                default: return "#1E293B"
                }
            }

            RowLayout {
                id: alertContent
                anchors.fill: parent
                anchors.leftMargin: STheme.spacingMd
                anchors.rightMargin: STheme.spacingSm
                anchors.topMargin: STheme.spacingSm
                anchors.bottomMargin: STheme.spacingSm
                spacing: STheme.spacingSm

                SIcon {
                    icon: {
                        switch (alertItem.alertType) {
                        case "success": return IconCodes.checkCircle
                        case "error": return IconCodes.errorIcon
                        case "warning": return IconCodes.warning
                        default: return IconCodes.info
                        }
                    }
                    size: 22
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignVCenter
                }

                SText {
                    text: alertItem.alertText
                    variant: "body"
                    color: "#FFFFFF"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Item {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    Layout.alignment: Qt.AlignVCenter

                    SIcon {
                        anchors.centerIn: parent
                        icon: IconCodes.close
                        size: 18
                        color: "#80FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.removeAt(alertItem.index)
                    }
                }
            }

            Timer {
                running: alertItem.closeTime > 0
                interval: alertItem.closeTime
                onTriggered: root.removeAt(alertItem.index)
            }
        }

        add: Transition {
            NumberAnimation {
                property: "y"
                from: 100
                duration: 400
                easing.type: Easing.OutBack
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: 250
                easing.type: Easing.InQuad
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }
}
