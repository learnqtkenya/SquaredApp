import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: counterPage
    title: ""

    property int count: Storage.get("count", 0)

    Item { Layout.fillHeight: true }

    SCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: STheme.spacingMd

            SIcon {
                icon: "\uead0"
                size: 48
                color: STheme.primary
                Layout.alignment: Qt.AlignHCenter
            }

            SText {
                text: counterPage.count.toString()
                font.pixelSize: 64
                font.weight: Font.DemiBold
                color: STheme.text
                Layout.alignment: Qt.AlignHCenter
            }

            SText {
                text: "Tap to count"
                variant: "caption"
                color: STheme.textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: STheme.spacingSm

        SButton {
            Layout.fillWidth: true
            text: "−"
            style: "Secondary"
            onClicked: () => { counterPage.count--; Storage.set("count", counterPage.count) }
        }

        SButton {
            Layout.fillWidth: true
            text: "+"
            style: "Primary"
            onClicked: () => { counterPage.count++; Storage.set("count", counterPage.count) }
        }
    }

    SButton {
        Layout.fillWidth: true
        text: "Reset"
        iconSource: IconCodes.refresh
        style: "Ghost"
        onClicked: () => { counterPage.count = 0; Storage.set("count", 0) }
    }

    Item { Layout.fillHeight: true }
}
