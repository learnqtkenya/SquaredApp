import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    id: root
    title: "Weather"

    property bool isLoading: true
    property bool hasError: false
    property string errorMessage: ""
    property var weather: null

    Component.onCompleted: {
        SecureStorage.get("weather_api_url")
            .then(function(value) {
                Network.baseUrl = value || "https://api.open-meteo.com"
                root.fetchWeather()
            })
            .error(function(msg) {
                Network.baseUrl = "https://api.open-meteo.com"
                root.fetchWeather()
            })
    }

    function fetchWeather() {
        isLoading = true
        hasError = false
        Network.get("/v1/forecast?latitude=40.71&longitude=-74.01"
                     + "&current=temperature_2m,relative_humidity_2m,"
                     + "apparent_temperature,wind_speed_10m,weather_code"
                     + "&temperature_unit=fahrenheit&wind_speed_unit=mph")
            .then(function(status, data) {
                weather = data.current
                isLoading = false
            })
            .error(function(status, msg) {
                errorMessage = msg
                hasError = true
                isLoading = false
            })
    }

    function weatherLabel(code) {
        if (code === 0) return "Clear Sky"
        if (code <= 3) return "Partly Cloudy"
        if (code <= 48) return "Foggy"
        if (code <= 55) return "Drizzle"
        if (code <= 65) return "Rainy"
        if (code <= 75) return "Snowy"
        if (code <= 82) return "Showers"
        return "Thunderstorm"
    }

    function weatherIcon(code) {
        if (code === 0) return "\ue430"        // wb_sunny
        if (code <= 3) return "\uf172"         // partly_cloudy_day
        if (code <= 48) return "\ue818"        // foggy
        if (code <= 65) return "\uf176"        // rainy
        if (code <= 75) return "\ue80f"        // weather_snowy
        if (code <= 82) return "\uf176"        // rainy
        return "\uf67e"                         // thunderstorm
    }

    // Loading state
    ColumnLayout {
        visible: root.isLoading
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: STheme.spacingMd

        Item { Layout.fillHeight: true }

        SLoadingSpinner {
            size: 48
            Layout.alignment: Qt.AlignHCenter
        }

        SText {
            text: "Fetching weather..."
            variant: "body"
            color: STheme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }
    }

    // Error state
    SEmptyState {
        visible: root.hasError && !root.isLoading
        Layout.fillWidth: true
        Layout.fillHeight: true
        title: "Could not load weather"
        description: root.errorMessage
        icon: IconCodes.warning
        actionText: "Retry"
        onActionClicked: root.fetchWeather()
    }

    // Weather content
    ColumnLayout {
        visible: root.weather !== null && !root.isLoading && !root.hasError
        Layout.fillWidth: true
        spacing: STheme.spacingMd

        Item { Layout.fillHeight: true }

        // Main weather icon + temperature
        SIcon {
            icon: root.weather ? weatherIcon(root.weather.weather_code) : ""
            size: 72
            color: STheme.primary
            Layout.alignment: Qt.AlignHCenter
        }

        SText {
            text: root.weather ? Math.round(root.weather.temperature_2m) + "\u00b0F" : ""
            variant: "heading"
            font.pixelSize: 56
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        SText {
            text: root.weather ? weatherLabel(root.weather.weather_code) : ""
            variant: "body"
            color: STheme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        SText {
            text: "New York, NY"
            variant: "caption"
            color: STheme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        SSpacer { size: STheme.spacingMd }

        // Metrics card
        SCard {
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                spacing: STheme.spacingMd

                SMetric {
                    Layout.fillWidth: true
                    icon: "\ue798"
                    value: root.weather ? Math.round(root.weather.relative_humidity_2m) + "%" : ""
                    label: "Humidity"
                }

                SMetric {
                    Layout.fillWidth: true
                    icon: "\ue63d"
                    value: root.weather ? root.weather.wind_speed_10m + " mph" : ""
                    label: "Wind"
                }

                SMetric {
                    Layout.fillWidth: true
                    icon: "\ue1ff"
                    value: root.weather ? Math.round(root.weather.apparent_temperature) + "\u00b0F" : ""
                    label: "Feels Like"
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Refresh button
        SButton {
            text: "Refresh"
            iconSource: IconCodes.refresh
            style: "Secondary"
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.fetchWeather()
        }

        SSpacer { size: STheme.spacingSm }
    }
}
