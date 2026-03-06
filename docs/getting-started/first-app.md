# Your First App

This guide walks you through creating, previewing, and packaging a Squared app.

## Create a Project

```bash
squared init hello-world
cd hello-world
```

This creates:

```
hello-world/
├── manifest.json
├── CMakeLists.txt
├── qml/
│   └── Main.qml
└── assets/
```

## Edit Your App

Open `qml/Main.qml` and replace the contents:

```qml
import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    title: "Hello World"

    SCard {
        Layout.fillWidth: true

        SCardHeader {
            title: "Welcome"
            subtitle: "My first Squared app"
        }

        SCardBody {
            SText {
                text: "Hello from Squared!"
                variant: "body"
            }

            SButton {
                text: "Click me"
                onClicked: toast.show("It works!", "success")
            }
        }
    }

    SToast { id: toast }
}
```

## Preview

Run your app with hot reload — changes to QML files trigger an automatic reload:

```bash
squared run
```

The Squared host app opens with your app loaded. Edit `Main.qml`, save, and see changes instantly.

Press `Ctrl+C` in the terminal or `Escape` in the app to exit.

## Add Persistence

Use the `Storage` API to save data:

```qml
import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    title: "Counter"

    property int count: Storage.get("count", 0)

    SCard {
        Layout.fillWidth: true

        SText {
            text: count
            variant: "heading"
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: STheme.spacingSm

            SButton {
                text: "-"
                style: "Secondary"
                onClicked: {
                    count--
                    Storage.set("count", count)
                }
            }

            SButton {
                text: "+"
                onClicked: {
                    count++
                    Storage.set("count", count)
                }
            }
        }
    }
}
```

`Storage` is automatically available — no imports or permissions needed. Data persists across app restarts, sandboxed per app.

## Validate

Check your app for errors before packaging:

```bash
squared validate
```

## Package

Create a `.sqapp` bundle:

```bash
squared package
```

This produces `com.developer.helloworld-1.0.0.sqapp` — a ZIP file ready for publishing.

## Publish

Upload to the Squared Store:

```bash
squared publish com.developer.helloworld-1.0.0.sqapp \
  --server https://your-store.example.com \
  --token YOUR_TOKEN
```

## What's Next?

- [UI Components](../ui/overview.md) — explore all 28 themed components
- [Storage API](../sdk/storage.md) — persistent key-value storage
- [Network API](../sdk/network.md) — HTTP requests from your app
- [Permissions](../guides/permissions.md) — access control for sensitive APIs
