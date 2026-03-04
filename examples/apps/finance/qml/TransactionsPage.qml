import QtQuick
import QtQuick.Layouts
import Squared.UI
import "DataManager.js" as Logic

Item {
    id: txPage

    required property Item app

    ColumnLayout {
        anchors.fill: parent
        spacing: STheme.spacingSm

        Item { Layout.preferredHeight: STheme.spacingXs }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd
            spacing: STheme.spacingSm

            SSearchField {
                Layout.fillWidth: true
                placeholderText: "Search..."
                onTextChanged: {
                    txPage.app.filterText = text
                    txPage.app.updateFilters()
                }
            }

            SDropdown {
                Layout.preferredWidth: 130
                model: ["All"].concat(txPage.app.categories)
                placeholderText: "Category"
                onActivated: (index) => {
                    txPage.app.filterCategory = index === 0 ? "" : currentText
                    txPage.app.updateFilters()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd
            spacing: STheme.spacingSm

            Repeater {
                model: [
                    { label: "All", value: "" },
                    { label: "Income", value: "income" },
                    { label: "Expense", value: "expense" }
                ]

                delegate: Rectangle {
                    required property var modelData

                    Layout.preferredHeight: 32
                    Layout.preferredWidth: badgeText.implicitWidth + STheme.spacingMd * 2
                    radius: STheme.radiusSmall
                    color: txPage.app.filterType === modelData.value
                           ? STheme.primary : STheme.surfaceVariant
                    border.width: 1
                    border.color: txPage.app.filterType === modelData.value
                                  ? STheme.primary : STheme.border

                    SText {
                        id: badgeText
                        anchors.centerIn: parent
                        text: modelData.label
                        variant: "caption"
                        color: txPage.app.filterType === modelData.value
                               ? STheme.surface : STheme.text
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            txPage.app.filterType = modelData.value
                            txPage.app.updateFilters()
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        SText {
            text: txPage.app.filteredTransactions.length + " transaction" +
                  (txPage.app.filteredTransactions.length !== 1 ? "s" : "")
            variant: "caption"
            color: STheme.textSecondary
            Layout.leftMargin: STheme.spacingMd
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: listContent.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: listContent
                width: parent.width
                spacing: 0

                SCard {
                    visible: txPage.app.filteredTransactions.length > 0
                    Layout.fillWidth: true
                    Layout.leftMargin: STheme.spacingMd
                    Layout.rightMargin: STheme.spacingMd

                    Repeater {
                        model: txPage.app.filteredTransactions

                        ColumnLayout {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            spacing: 0

                            SDivider { visible: index > 0 }

                            SListItem {
                                title: modelData.description || ""
                                subtitle: Logic.formatDate(modelData.date) +
                                          " · " + (modelData.category || "")
                                icon: modelData.type === "income"
                                      ? IconCodes.trendingUp : IconCodes.trendingDown
                                trailing: Component {
                                    RowLayout {
                                        spacing: STheme.spacingXs

                                        SText {
                                            text: (modelData.type === "income" ? "+" : "-") +
                                                  Logic.formatCurrency(modelData.amount)
                                            variant: "body"
                                            color: modelData.type === "income" ? "#22C55E" : STheme.error
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        SButton {
                                            iconSource: IconCodes.deleteIcon
                                            text: ""
                                            style: "Ghost"
                                            onClicked: txPage.app.removeTransaction(modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                SEmptyState {
                    visible: txPage.app.filteredTransactions.length === 0
                    Layout.fillWidth: true
                    Layout.topMargin: STheme.spacingXl
                    title: txPage.app.transactions.length === 0
                           ? "No transactions yet" : "No matches"
                    description: txPage.app.transactions.length === 0
                                 ? "Add a transaction to get started"
                                 : "Try adjusting your search or filters"
                    icon: IconCodes.search
                }

                Item { Layout.preferredHeight: STheme.spacingMd }
            }
        }
    }
}
