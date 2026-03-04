import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Squared.UI
import "DataManager.js" as Logic

Rectangle {
    id: root
    color: STheme.background

    // --- Navigation State ---
    property int currentTab: 0

    // --- Data State ---
    property var transactions: []
    property var filteredTransactions: []
    property var recentTransactions: []
    property double totalIncome: 0.0
    property double totalExpenses: 0.0
    property double balance: 0.0
    property string filterText: ""
    property string filterCategory: ""
    property string filterType: ""
    readonly property var categories: ["Food", "Transport", "Shopping", "Bills",
                                       "Entertainment", "Health", "Salary", "Freelance", "Other"]

    // --- Actions ---
    function loadFromStorage() {
        var raw = Storage.get("transactions", [])
        // QVariantList from C++ may not pass Array.isArray() — use length check instead
        if (raw && typeof raw.length === "number") {
            // Convert QVariantList to a real JS array
            var arr = []
            for (var i = 0; i < raw.length; i++)
                arr.push(raw[i])
            transactions = arr
        } else {
            transactions = []
        }
        recalculate()
    }

    function addTransaction(desc, amount, cat, type) {
        var tx = Logic.createTransaction(desc, amount, cat, type)
        transactions = [tx].concat(transactions)
        Storage.set("transactions", transactions)
        recalculate()
    }

    function removeTransaction(txId) {
        transactions = transactions.filter(function(t) { return t.id !== txId })
        Storage.set("transactions", transactions)
        recalculate()
    }

    function updateFilters() {
        filteredTransactions = Logic.applyFilters(transactions, filterText, filterCategory, filterType)
    }

    function recalculate() {
        var totals = Logic.calculateTotals(transactions)
        totalIncome = totals.income
        totalExpenses = totals.expenses
        balance = totals.balance
        recentTransactions = transactions.slice(0, 5)
        updateFilters()
    }

    Component.onCompleted: loadFromStorage()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StackView {
            id: navStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: dashboardPage
        }

        SDivider {}

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: [
                    { label: "Dashboard", icon: IconCodes.dashboard, idx: 0 },
                    { label: "History", icon: IconCodes.receipt, idx: 1 },
                    { label: "Add", icon: IconCodes.add, idx: 2 }
                ]

                delegate: Item {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: tabCol.implicitHeight + STheme.spacingSm * 2

                    ColumnLayout {
                        id: tabCol
                        anchors.centerIn: parent
                        spacing: 2

                        SIcon {
                            icon: modelData.icon
                            size: 22
                            color: root.currentTab === modelData.idx ? STheme.primary : STheme.textSecondary
                            Layout.alignment: Qt.AlignHCenter
                        }

                        SText {
                            text: modelData.label
                            variant: "caption"
                            color: root.currentTab === modelData.idx ? STheme.primary : STheme.textSecondary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentTab === modelData.idx) return
                            root.currentTab = modelData.idx
                            switch (modelData.idx) {
                            case 0: navStack.replace(null, dashboardPage); break
                            case 1: navStack.replace(null, transactionsPage); break
                            case 2: navStack.replace(null, addTransactionPage); break
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: dashboardPage
        DashboardPage { app: root }
    }

    Component {
        id: transactionsPage
        TransactionsPage { app: root }
    }

    Component {
        id: addTransactionPage
        AddTransactionPage {
            app: root
            onTransactionAdded: {
                root.currentTab = 0
                navStack.replace(null, dashboardPage)
            }
        }
    }
}
