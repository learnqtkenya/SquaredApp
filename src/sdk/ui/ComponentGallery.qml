import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Squared.UI

Window {
    id: root
    width: 480
    height: 800
    visible: true
    title: "Squared.UI Component Gallery"
    color: STheme.background

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: root.width
            spacing: STheme.spacingLg

            Item { Layout.preferredHeight: STheme.spacingMd }

            // ── SText ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SText"
                SText { text: "Heading"; variant: "heading" }
                SText { text: "Subheading"; variant: "subheading" }
                SText { text: "Body text — the default variant"; variant: "body" }
                SText { text: "Caption text"; variant: "caption"; color: STheme.textSecondary }
            }

            // ── SIcon ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SIcon"
                RowLayout {
                    spacing: STheme.spacingMd
                    SIcon { icon: IconCodes.home; size: 24 }
                    SIcon { icon: IconCodes.search; size: 24 }
                    SIcon { icon: IconCodes.settings; size: 24 }
                    SIcon { icon: IconCodes.favorite; size: 24; color: STheme.error }
                    SIcon { icon: IconCodes.star; size: 24; color: "#FBBF24" }
                    SIcon { icon: IconCodes.notification; size: 24; color: STheme.primary }
                }
            }

            // ── SButton ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SButton"
                ColumnLayout {
                    spacing: STheme.spacingSm
                    SButton { text: "Primary"; style: "Primary" }
                    SButton { text: "Secondary"; style: "Secondary" }
                    SButton { text: "Ghost"; style: "Ghost" }
                    SButton { text: "Danger"; style: "Danger" }
                    SButton { text: "Disabled"; enabled: false }
                    SButton { text: "With Icon"; iconSource: IconCodes.add; style: "Primary" }
                }
            }

            // ── SDivider ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SDivider"
                SDivider {}
            }

            // ── SSpacer ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SSpacer"
                RowLayout {
                    spacing: 0
                    Rectangle { Layout.preferredWidth: 40; Layout.preferredHeight: 40; color: STheme.primary; radius: STheme.radiusSmall }
                    SSpacer { size: STheme.spacingXl }
                    Rectangle { Layout.preferredWidth: 40; Layout.preferredHeight: 40; color: STheme.primaryVariant; radius: STheme.radiusSmall }
                }
            }

            // ── SCard + SCardHeader + SCardBody ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SCard / SCardHeader / SCardBody"
                SCard {
                    SCardHeader { title: "Card Title"; subtitle: "With a subtitle" }
                    SCardBody {
                        SText { text: "This is content inside an SCardBody." }
                    }
                }
            }

            // ── SListItem ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SListItem"
                ColumnLayout {
                    Layout.fillWidth: true
                    SListItem { title: "Home"; subtitle: "Go to home screen"; icon: IconCodes.home }
                    SListItem { title: "Settings"; icon: IconCodes.settings }
                    SListItem { title: "Profile"; subtitle: "View your profile"; icon: IconCodes.person }
                }
            }

            // ── SBadge ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SBadge"
                RowLayout {
                    spacing: STheme.spacingSm
                    SBadge { text: "New" }
                    SBadge { text: "Live"; badgeColor: STheme.success }
                    SBadge { text: "Error"; badgeColor: STheme.error }
                    SBadge { text: "Custom"; badgeColor: "#F59E0B"; textColor: "#000000" }
                }
            }

            // ── STextField ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "STextField"
                STextField { placeholderText: "Enter your name..." }
                STextField { text: "Pre-filled value" }
                STextField { placeholderText: "Disabled"; enabled: false }
            }

            // ── SSwitch ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SSwitch"
                SSwitch { text: "Notifications"; checked: true }
                SSwitch { text: "Dark Mode" }
                SSwitch { text: "Disabled"; enabled: false }
            }

            // ── SSearchField ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SSearchField"
                SSearchField {}
                SSearchField { text: "typed query" }
            }

            // ── SProgressBar ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SProgressBar"
                SText { text: "Determinate (75%)"; variant: "caption" }
                SProgressBar { value: 0.75; Layout.fillWidth: true }
                SSpacer { size: STheme.spacingSm }
                SText { text: "Indeterminate"; variant: "caption" }
                SProgressBar { indeterminate: true; Layout.fillWidth: true }
            }

            // ── SLoadingSpinner ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SLoadingSpinner"
                RowLayout {
                    spacing: STheme.spacingMd
                    SLoadingSpinner { size: 24 }
                    SLoadingSpinner { size: 32 }
                    SLoadingSpinner { size: 48; color: STheme.error }
                }
            }

            // ── SEmptyState ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SEmptyState"
                SEmptyState {
                    icon: IconCodes.empty
                    title: "No items yet"
                    description: "Tap the button below to add your first item"
                    actionText: "Add Item"
                }
            }

            // ── SMetric ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SMetric"
                RowLayout {
                    spacing: STheme.spacingXl
                    SMetric { value: 1234; label: "Users" }
                    SMetric { value: "99.9%"; label: "Uptime"; icon: IconCodes.checkCircle }
                    SMetric { value: 42; label: "Tasks"; icon: IconCodes.dashboard }
                }
            }

            // ── SToast ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SToast"
                SText { text: "Click buttons to show toasts"; variant: "caption"; color: STheme.textSecondary }
                RowLayout {
                    spacing: STheme.spacingSm
                    SButton {
                        text: "Info"
                        style: "Secondary"
                        onClicked: toast.show("This is an info toast", "info")
                    }
                    SButton {
                        text: "Success"
                        style: "Secondary"
                        onClicked: toast.show("Operation successful!", "success")
                    }
                    SButton {
                        text: "Error"
                        style: "Danger"
                        onClicked: toast.show("Something went wrong", "error")
                    }
                }
            }

            // ── SDialog ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SDialog"
                SButton {
                    text: "Open Dialog"
                    style: "Secondary"
                    onClicked: dialog.open()
                }
            }

            // ── SDropdown ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SDropdown"
                SDropdown { model: ["Apple", "Banana", "Cherry", "Date"] }
            }

            // ── SCheckbox ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SCheckbox"
                SCheckbox { text: "Accept terms and conditions" }
                SCheckbox { text: "Subscribe to newsletter"; checked: true }
                SCheckbox { text: "Disabled option"; enabled: false }
            }

            // ── SRadioGroup ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SRadioGroup"
                SRadioGroup {
                    model: ["Small", "Medium", "Large"]
                    currentIndex: 1
                }
            }

            // ── SSlider ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SSlider"
                SSlider { from: 0; to: 100; value: 50; Layout.fillWidth: true }
            }

            // ── SGrid ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SGrid"
                SGrid {
                    Layout.fillWidth: true
                    minColumnWidth: 100
                    Repeater {
                        model: 6
                        SCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            SText {
                                text: "Cell " + (index + 1)
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            }
                        }
                    }
                }
            }

            // ── SAvatar ──
            SSection {
                Layout.fillWidth: true
                Layout.leftMargin: STheme.spacingMd
                Layout.rightMargin: STheme.spacingMd
                title: "SAvatar"
                RowLayout {
                    spacing: STheme.spacingMd
                    SAvatar { initials: "JD"; size: 32 }
                    SAvatar { initials: "AB"; size: 40 }
                    SAvatar { initials: "ZX"; size: 56 }
                }
            }

            // Bottom padding
            SSpacer { size: STheme.spacingXl }
        }
    }

    // Overlay components
    SToast { id: toast }

    SDialog {
        id: dialog
        title: "Example Dialog"
        acceptText: "Confirm"
        rejectText: "Cancel"

        SText { text: "This is dialog content. Do you want to proceed?" }
    }
}
