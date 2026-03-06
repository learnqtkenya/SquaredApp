# Packaging & Publishing

## .sqapp Format

A `.sqapp` file is a ZIP archive with this structure:

```
myapp.sqapp
├── manifest.json          # App metadata (required)
├── qml/
│   ├── Main.qml           # Entry point
│   └── *.qml              # Additional components
└── assets/
    ├── icon.png            # App icon
    └── ...                 # Other assets
```

## Creating a Package

### With the CLI

```bash
cd my-app
squared package
```

This validates the app, then creates `<id>-<version>.sqapp` in the current directory.

Custom output path:

```bash
squared package --output dist/my-app.sqapp
```

### What's included

Everything in the app directory except:

- Hidden files/directories (`.git`, `.env`, etc.)
- Build artifacts (`build/`, `node_modules/`, `__pycache__/`)
- Python bytecode (`.pyc`)
- Existing `.sqapp` files

### Naming convention

Default: `<id>-<version>.sqapp`

Example: `com.squared.weather-1.0.0.sqapp`

## Publishing to the Store

### Upload metadata

```bash
squared publish my-app.sqapp \
    --server https://your-store.example.com \
    --token YOUR_TOKEN \
    --package-url https://cdn.example.com/my-app.sqapp
```

| Flag | Default | Description |
|------|---------|-------------|
| `--server` | `$SQUARED_SERVER_URL` or `http://localhost:8080` | Store server URL |
| `--token` | `$SQUARED_TOKEN` | Authentication token |
| `--package-url` | (empty) | Download URL for the package |

The CLI reads `manifest.json` from the ZIP and sends the metadata to the store's `/api/apps` endpoint.

### Server responses

| Status | Meaning |
|--------|---------|
| 201 Created | Published successfully |
| 409 Conflict | Version already exists |
| 401 Unauthorized | Invalid or missing token |

## Installation Flow

When a user taps "Get" in the store:

1. Host app downloads `.sqapp` from the `packageUrl`
2. `AppInstaller` extracts to temp, validates manifest
3. Copies to `<installDir>/<appId>/`
4. `AppRegistry` records metadata (name, icon, color, version)
5. App appears in the home grid

## Uninstallation

When a user uninstalls:

1. App files removed from `<installDir>/<appId>/`
2. App storage removed from `<storageRoot>/<appId>/`
3. Secure storage keys cleaned from system keychain
4. Registry entry removed

## Store Server

The store backend is a Go server with PostgreSQL. Run locally:

```bash
cd server
docker compose up
```

### Authentication

Write endpoints (create, update, delete) require an admin token passed as a Bearer token in the `Authorization` header:

```
Authorization: Bearer <ADMIN_TOKEN>
```

The token is configured on the server via the `ADMIN_TOKEN` environment variable. When empty, authentication is disabled (useful for local development).

Read endpoints (catalog, list, get) are public and require no authentication.

### API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/catalog` | No | Full catalog (supports ETag caching) |
| GET | `/api/apps` | No | List all apps |
| GET | `/api/apps/:id` | No | Get app by ID |
| POST | `/api/apps` | **Yes** | Create app |
| PUT | `/api/apps/:id` | **Yes** | Update app |
| DELETE | `/api/apps/:id` | **Yes** | Delete app |
| GET | `/healthz` | No | Liveness check |
| GET | `/readyz` | No | Readiness check |

### Catalog Entry Fields

```json
{
    "id": "com.squared.weather",
    "name": "Weather",
    "version": "1.0.0",
    "author": "Squared Computing",
    "description": "Live weather app",
    "category": "Utility",
    "icon": "\ue2bd",
    "color": "#FF9800",
    "packageUrl": "https://cdn.example.com/weather.sqapp",
    "sizeBytes": 12345,
    "permissions": ["network", "secure-storage"]
}
```
