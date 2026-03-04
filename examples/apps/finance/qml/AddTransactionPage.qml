import QtQuick
import QtQuick.Layouts
import Squared.UI

Flickable {
    id: addPage

    required property Item app
    signal transactionAdded()

    property bool isIncome: false

    contentHeight: content.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: content
        width: parent.width
        spacing: STheme.spacingMd

        Item { Layout.preferredHeight: STheme.spacingSm }

        SText {
            text: "New Transaction"
            variant: "subheading"
            Layout.leftMargin: STheme.spacingMd
        }

        SCard {
            Layout.fillWidth: true
            Layout.leftMargin: STheme.spacingMd
            Layout.rightMargin: STheme.spacingMd

            ColumnLayout {
                Layout.fillWidth: true
                spacing: STheme.spacingMd

                RowLayout {
                    Layout.fillWidth: true
                    spacing: STheme.spacingSm

                    SButton {
                        Layout.fillWidth: true
                        text: "Income"
                        iconSource: IconCodes.trendingUp
                        style: addPage.isIncome ? "Primary" : "Secondary"
                        onClicked: addPage.isIncome = true
                    }

                    SButton {
                        Layout.fillWidth: true
                        text: "Expense"
                        iconSource: IconCodes.trendingDown
                        style: !addPage.isIncome ? "Danger" : "Secondary"
                        onClicked: addPage.isIncome = false
                    }
                }

                SDivider {}

                SText {
                    text: "Amount"
                    variant: "caption"
                    color: STheme.textSecondary
                }

                STextField {
                    id: amountField
                    Layout.fillWidth: true
                    placeholderText: "0.00"
                }

                SText {
                    text: "Description"
                    variant: "caption"
                    color: STheme.textSecondary
                }

                STextField {
                    id: descField
                    Layout.fillWidth: true
                    placeholderText: "What was this for?"
                }

                SText {
                    text: "Category"
                    variant: "caption"
                    color: STheme.textSecondary
                }

                SDropdown {
                    id: categoryDropdown
                    Layout.fillWidth: true
                    model: addPage.app.categories
                    placeholderText: "Select category"
                }

                SSpacer { size: STheme.spacingSm }

                SButton {
                    Layout.fillWidth: true
                    text: "Add Transaction"
                    iconSource: IconCodes.add
                    style: "Primary"
                    enabled: amountField.text.trim() !== "" && descField.text.trim() !== ""
                    onClicked: {
                        var amount = parseFloat(amountField.text)
                        if (isNaN(amount) || amount <= 0) return

                        addPage.app.addTransaction(
                            descField.text.trim(),
                            amount,
                            categoryDropdown.currentText || addPage.app.categories[0],
                            addPage.isIncome ? "income" : "expense"
                        )

                        amountField.text = ""
                        descField.text = ""
                        categoryDropdown.currentIndex = 0
                        addPage.isIncome = false

                        addPage.transactionAdded()
                    }
                }
            }
        }

        Item { Layout.preferredHeight: STheme.spacingMd }
    }
}
