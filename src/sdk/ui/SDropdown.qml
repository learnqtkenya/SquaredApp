import QtQuick
import QtQuick.Controls

ComboBox {
    id: root

    property string placeholderText: "Select..."

    implicitWidth: 280
    implicitHeight: 44

    font: STheme.body

    contentItem: SText {
        text: root.currentIndex >= 0 ? root.currentText : root.placeholderText
        variant: "body"
        color: root.currentIndex >= 0 ? STheme.text : STheme.textSecondary
        verticalAlignment: Text.AlignVCenter
        leftPadding: STheme.spacingMd
        rightPadding: STheme.spacingXl
        elide: Text.ElideRight
    }

    indicator: SIcon {
        icon: IconCodes.expandMore
        size: 20
        color: STheme.textSecondary
        anchors.right: parent.right
        anchors.rightMargin: STheme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
    }

    background: Rectangle {
        radius: STheme.radiusSmall
        color: STheme.surface
        border.width: root.pressed || root.activeFocus ? 2 : 1
        border.color: root.pressed || root.activeFocus ? STheme.primary : STheme.border
    }

    popup: Popup {
        y: root.height + STheme.spacingXs
        width: root.width
        padding: STheme.spacingXs

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.delegateModel
            currentIndex: root.highlightedIndex
        }

        background: Rectangle {
            radius: STheme.radiusSmall
            color: STheme.surface
            border.width: 1
            border.color: STheme.border
        }
    }

    delegate: ItemDelegate {
        width: root.width
        height: 40

        contentItem: SText {
            text: modelData !== undefined ? modelData : model[root.textRole]
            variant: "body"
            color: highlighted ? STheme.primary : STheme.text
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: highlighted ? STheme.surfaceVariant : "transparent"
            radius: STheme.radiusSmall
        }

        highlighted: root.highlightedIndex === index
    }
}
