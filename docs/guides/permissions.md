# Permissions

Squared apps run in a sandbox. Sensitive APIs require explicit permissions declared in `manifest.json`.

## Available Permissions

| Permission | API Granted | Description |
|------------|-------------|-------------|
| `network` | `Network` | HTTP requests via [NetworkClient](../sdk/network.md) |
| `secure-storage` | `SecureStorage` | Encrypted key-value storage via [SecureStorage](../sdk/secure-storage.md) |

## Always Available (No Permission Needed)

| API | Description |
|-----|-------------|
| `Storage` | [Key-value persistence](../sdk/storage.md) |
| `App` | [App metadata and lifecycle](../sdk/app-lifecycle.md) |

## Declaring Permissions

Add a `permissions` array to your `manifest.json`:

```json
{
    "id": "com.example.myapp",
    "name": "My App",
    "version": "1.0.0",
    "permissions": ["network", "secure-storage"]
}
```

## How It Works

When the `AppRunner` launches an app:

1. It reads `manifest.json` and checks the `permissions` array
2. `Storage` and `App` are always injected into the app's context
3. `Network` is only injected if `"network"` is in permissions
4. `SecureStorage` is only injected if `"secure-storage"` is in permissions

If your code references an API that wasn't granted, the context property will be `undefined`:

```qml
// Without "network" permission, this will fail:
Network.get("/data")  // TypeError: Cannot read property 'get' of undefined
```

## Checking Permissions at Runtime

You can guard against missing permissions:

```qml
SButton {
    text: "Fetch Data"
    visible: typeof Network !== "undefined"
    onClicked: Network.get("/data").then(handleResult)
}

SEmptyState {
    visible: typeof Network === "undefined"
    title: "Network not available"
    description: "This feature requires network permission"
}
```

## Store Display

The store page shows permission badges on apps that require sensitive APIs, so users know what an app needs before installing.

## Best Practices

- **Request only what you need.** Don't declare `network` if your app works offline.
- **Degrade gracefully.** If a permission might not be granted in the future, check before using the API.
- **Document why.** Use your app's `description` to explain why permissions are needed (e.g., "Fetches live weather data").
