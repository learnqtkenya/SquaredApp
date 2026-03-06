# Network

HTTP client for making API requests. Requires the `network` [permission](../guides/permissions.md).

Available as the `Network` context property when the permission is granted.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `baseUrl` | `url` | (empty) | Base URL prepended to all request paths |
| `bearerToken` | `string` | (empty) | Token added as `Authorization: Bearer <token>` header |
| `timeout` | `int` | `30000` | Request timeout in milliseconds |

## Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `get(path)` | `NetworkReply` | HTTP GET |
| `post(path, body)` | `NetworkReply` | HTTP POST with JSON body |
| `put(path, body)` | `NetworkReply` | HTTP PUT with JSON body |
| `patch(path, body)` | `NetworkReply` | HTTP PATCH with JSON body |
| `del(path)` | `NetworkReply` | HTTP DELETE |
| `setHeader(name, value)` | void | Set a custom header |
| `clearHeaders()` | void | Remove all custom headers |

## Reply Pattern

Every HTTP method returns a `NetworkReply` with:

| Member | Type | Description |
|--------|------|-------------|
| `then(callback)` | method | Called on success with response data (parsed JSON) |
| `error(callback)` | method | Called on failure with error message |
| `abort()` | method | Cancel the request |
| `loading` | property | `true` while the request is in progress |

Chainable — `.then()` and `.error()` both return the reply.

## Usage

### Simple GET

```qml
Network.baseUrl = "https://api.example.com"

Network.get("/users/1")
    .then(function(data) {
        nameLabel.text = data.name
    })
    .error(function(err) {
        toast.show("Failed: " + err, "error")
    })
```

### POST with JSON body

```qml
Network.post("/todos", {
    title: "Buy groceries",
    completed: false
}).then(function(data) {
    toast.show("Created: " + data.id, "success")
})
```

### Authentication

```qml
// Set bearer token once
Network.bearerToken = "sk-abc123"

// All subsequent requests include the Authorization header
Network.get("/me").then(function(user) {
    console.log("Logged in as", user.name)
})
```

### Custom headers

```qml
Network.setHeader("X-Custom", "value")
Network.get("/endpoint").then(function(data) {
    // ...
})
Network.clearHeaders()
```

### Loading state

```qml
property var weatherReply: null

SButton {
    text: weatherReply && weatherReply.loading ? "Loading..." : "Fetch Weather"
    onClicked: {
        weatherReply = Network.get("/weather?city=nairobi")
            .then(function(data) {
                tempLabel.text = data.temp + " C"
            })
    }
}
```

### Cancellation

```qml
property var currentReply: null

function search(query) {
    if (currentReply)
        currentReply.abort()
    currentReply = Network.get("/search?q=" + query)
        .then(function(results) { /* ... */ })
}
```

## Manifest Permission

Your `manifest.json` must include the `network` permission:

```json
{
    "permissions": ["network"]
}
```

Without this permission, the `Network` context property is not injected and will be `undefined`.

## Implementation Details

- **Backend:** `QRestAccessManager` with `QNetworkRequestFactory`
- **Body encoding:** JSON (`Content-Type: application/json`)
- **Response parsing:** Automatic JSON parse (passed as JS object to `.then()`)
- **Sandboxed:** Each app gets its own `NetworkClient` instance with independent headers and base URL
