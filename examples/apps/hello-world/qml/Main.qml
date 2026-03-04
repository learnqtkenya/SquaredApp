import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    title: "Hello World"

    Item { Layout.fillHeight: true }

    SIcon {
        icon: "\ue9b2"
        size: 64
        color: STheme.primary
        Layout.alignment: Qt.AlignHCenter
    }

    SSpacer { size: STheme.spacingSm }

    SText {
        text: "Hello from Squared!"
        variant: "heading"
        Layout.alignment: Qt.AlignHCenter
    }

    SText {
        text: "This mini app loaded successfully."
        variant: "body"
        color: STheme.textSecondary
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
    }

    SSpacer { size: STheme.spacingLg }

    SCard {
        SListItem {
            title: "App ID"
            subtitle: App.appId
            icon: IconCodes.code
        }

        SDivider {}

        SListItem {
            title: "App Version"
            subtitle: App.appVersion
            icon: IconCodes.category
        }

        SDivider {}

        SListItem {
            title: "Host Version"
            subtitle: "Squared v" + App.hostVersion
            icon: IconCodes.info
        }
    }

    Item { Layout.fillHeight: true }
}
