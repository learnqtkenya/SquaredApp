.pragma library

function generateId() {
    return "xxxx-xxxx-xxxx".replace(/x/g, function() {
        return Math.floor(Math.random() * 16).toString(16)
    })
}

function formatCurrency(amount) {
    var abs = Math.abs(amount)
    var parts = abs.toFixed(2).split(".")
    var intPart = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return (amount < 0 ? "-" : "") + "$" + intPart + "." + parts[1]
}

function formatDate(isoString) {
    var d = new Date(isoString)
    var months = ["Jan","Feb","Mar","Apr","May","Jun",
                  "Jul","Aug","Sep","Oct","Nov","Dec"]
    return months[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear()
}

function calculateTotals(transactions) {
    var inc = 0, exp = 0
    for (var i = 0; i < transactions.length; i++) {
        if (transactions[i].type === "income")
            inc += transactions[i].amount
        else
            exp += transactions[i].amount
    }
    return { income: inc, expenses: exp, balance: inc - exp }
}

function applyFilters(transactions, filterText, filterCategory, filterType) {
    var result = transactions
    if (filterText !== "") {
        var lower = filterText.toLowerCase()
        result = result.filter(function(t) {
            return (t.description || "").toLowerCase().indexOf(lower) >= 0
        })
    }
    if (filterCategory !== "") {
        result = result.filter(function(t) { return t.category === filterCategory })
    }
    if (filterType !== "") {
        result = result.filter(function(t) { return t.type === filterType })
    }
    return result
}

function createTransaction(desc, amount, cat, type) {
    return {
        id: generateId(),
        description: desc,
        amount: amount,
        category: cat,
        type: type,
        date: new Date().toISOString()
    }
}
