CREATE TABLE app_secrets (
    app_id          TEXT NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    key             TEXT NOT NULL,
    encrypted_value BYTEA NOT NULL,
    PRIMARY KEY (app_id, key)
);
