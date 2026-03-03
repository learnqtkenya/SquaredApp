import QtQuick

Text {
    id: root

    property string variant: "body"

    color: STheme.text
    font: {
        switch (variant) {
        case "heading": return STheme.heading
        case "subheading": return STheme.subheading
        case "caption": return STheme.caption
        default: return STheme.body
        }
    }
    wrapMode: Text.Wrap
}
