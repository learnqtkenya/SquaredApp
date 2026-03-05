CREATE TABLE IF NOT EXISTS apps (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL CHECK (name <> ''),
    version     TEXT NOT NULL DEFAULT '1.0.0',
    author      TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    icon_url    TEXT NOT NULL DEFAULT '',
    package_url TEXT NOT NULL DEFAULT '',
    size_bytes  BIGINT NOT NULL DEFAULT 0,
    category    TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_apps_category ON apps (category);
CREATE INDEX IF NOT EXISTS idx_apps_name ON apps (name);
