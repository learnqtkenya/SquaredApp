import QtQuick
import QtQuick.Layouts
import Squared.UI
import "DataManager.js" as Logic

Flickable {
    id: dashPage

    required property Item app

    contentHeight: content.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: content
        width: parent.width
        spacing: STheme.spacingMd

        Item { Layout.preferredHeight: STheme.spacingSm }

        SCard {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd

            ColumnLayout {
                Layout.fillWidth: true
                spacing: STheme.spacingXs

                SText {
                    text: "Balance"
                    variant: "caption"
                    color: STheme.textSecondary
                }

                SText {
                    text: Logic.formatCurrency(dashPage.app.balance)
                    variant: "heading"
                    color: dashPage.app.balance >= 0 ? STheme.text : STheme.error
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd
            spacing: STheme.spacingSm

            SCard {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: STheme.radiusSmall
                        color: "#22C55E"
                        opacity: 0.12

                        SIcon {
                            anchors.centerIn: parent
                            icon: IconCodes.trendingUp
                            size: 20
                            color: "#22C55E"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        SText {
                            text: "Income"
                            variant: "caption"
                            color: STheme.textSecondary
                        }
                        SText {
                            text: Logic.formatCurrency(dashPage.app.totalIncome)
                            variant: "body"
                            color: "#22C55E"
                        }
                    }
                }
            }

            SCard {
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: STheme.radiusSmall
                        color: STheme.error
                        opacity: 0.12

                        SIcon {
                            anchors.centerIn: parent
                            icon: IconCodes.trendingDown
                            size: 20
                            color: STheme.error
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        SText {
                            text: "Expenses"
                            variant: "caption"
                            color: STheme.textSecondary
                        }
                        SText {
                            text: Logic.formatCurrency(dashPage.app.totalExpenses)
                            variant: "body"
                            color: STheme.error
                        }
                    }
                }
            }
        }

        SText {
            text: "Recent Transactions"
            variant: "subheading"
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd
        }

        SCard {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd
            visible: dashPage.app.recentTransactions.length > 0

            Repeater {
                model: dashPage.app.recentTransactions

                ColumnLayout {
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    spacing: 0

                    SDivider { visible: index > 0 }

                    SListItem {
                        title: modelData.description || ""
                        subtitle: Logic.formatDate(modelData.date) + " · " + (modelData.category || "")
                        icon: modelData.type === "income" ? IconCodes.trendingUp : IconCodes.trendingDown
                        trailing: Component {
                            SText {
                                text: (modelData.type === "income" ? "+" : "-") +
                                      Logic.formatCurrency(modelData.amount)
                                variant: "body"
                                color: modelData.type === "income" ? "#22C55E" : STheme.error
                            }
                        }
                    }
                }
            }
        }

        SEmptyState {
            visible: dashPage.app.transactions.length === 0
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd
            title: "No transactions yet"
            description: "Add your first transaction to start tracking"
            icon: IconCodes.wallet
        }

        Item { Layout.preferredHeight: STheme.spacingMd }
    }
}
