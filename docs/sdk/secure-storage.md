# Secure Storage

Asynchronous encrypted key-value storage backed by the system keychain. Requires the `secure-storage` [permission](../guides/permissions.md).

Available as the `SecureStorage` context property when the permission is granted.

## API

| Method | Returns | Description |
|--------|---------|-------------|
| `set(key, value)` | `SecureStorageReply` | Store a secret |
| `get(key)` | `SecureStorageReply` | Retrieve a secret |
| `remove(key)` | `SecureStorageReply` | Delete a secret |

All methods are **asynchronous** and return a chainable reply object.

## Reply Pattern

Every method returns a `SecureStorageReply` with:

| Member | Type | Description |
|--------|------|-------------|
| `then(callback)` | method | Called on success with the value (string) |
| `error(callback)` | method | Called on failure with error message |
| `loading` | property | `true` while the operation is in progress |

Both `.then()` and `.error()` return the reply, so calls are chainable:

```qml
SecureStorage.get("api-key")
    .then(function(value) {
        console.log("Got:", value)
    })
    .error(function(err) {
        console.log("Failed:", err)
    })
```

## Usage

### Store a token

```qml
SButton {
    text: "Save Token"
    onClicked: {
        SecureStorage.set("token", "sk-abc123")
            .then(function() {
                toast.show("Saved", "success")
            })
            .error(function(err) {
                toast.show("Error: " + err, "error")
            })
    }
}
```

### Read a token

```qml
Component.onCompleted: {
    SecureStorage.get("token")
        .then(function(value) {
            if (value !== "")
                apiToken = value
        })
        .error(function(err) {
            console.warn("No token:", err)
        })
}
```

### Delete a secret

```qml
SecureStorage.remove("token")
    .then(function() {
        console.log("Deleted")
    })
```

### Loading state

```qml
SecureStorageReply {
    id: tokenReply
}

SButton {
    text: tokenReply.loading ? "Loading..." : "Load Token"
    enabled: !tokenReply.loading
    onClicked: {
        tokenReply = SecureStorage.get("token")
            .then(function(val) { tokenField.text = val })
    }
}
```

## Manifest Permission

Your `manifest.json` must include the `secure-storage` permission:

```json
{
    "permissions": ["secure-storage"]
}
```

Without this permission, the `SecureStorage` context property is not injected and will be `undefined`.

## Implementation Details

- **Backend:** QKeychain (system keyring — Keychain on macOS, libsecret on Linux, Credential Manager on Windows)
- **Key format:** `<appId>/<key>` under service name `"squared"`
- **Sandboxed:** Apps can only access their own keys
- **Cleanup:** All keys are removed when the app is uninstalled
