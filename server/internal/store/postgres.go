package store

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgerrcode"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
	"squared-store/internal/crypto"
	"squared-store/internal/model"
)

type PostgresStore struct {
	pool       *pgxpool.Pool
	secretsKey []byte
}

func NewPostgresStore(pool *pgxpool.Pool, secretsKey []byte) *PostgresStore {
	return &PostgresStore{pool: pool, secretsKey: secretsKey}
}

func (s *PostgresStore) List(ctx context.Context) ([]model.App, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, name, version, author, description, icon_url, package_url,
		       size_bytes, category, icon, color, created_at, updated_at
		FROM apps ORDER BY name`)
	if err != nil {
		return nil, fmt.Errorf("list apps: %w", err)
	}
	defer rows.Close()

	var apps []model.App
	for rows.Next() {
		var a model.App
		if err := rows.Scan(&a.ID, &a.Name, &a.Version, &a.Author, &a.Description,
			&a.IconURL, &a.PackageURL, &a.SizeBytes, &a.Category,
			&a.Icon, &a.Color,
			&a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan app: %w", err)
		}
		apps = append(apps, a)
	}
	if apps == nil {
		apps = []model.App{}
	}
	return apps, rows.Err()
}

func (s *PostgresStore) GetByID(ctx context.Context, id string) (model.App, error) {
	var a model.App
	err := s.pool.QueryRow(ctx, `
		SELECT id, name, version, author, description, icon_url, package_url,
		       size_bytes, category, icon, color, created_at, updated_at
		FROM apps WHERE id = $1`, id).Scan(
		&a.ID, &a.Name, &a.Version, &a.Author, &a.Description,
		&a.IconURL, &a.PackageURL, &a.SizeBytes, &a.Category,
		&a.Icon, &a.Color,
		&a.CreatedAt, &a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return a, fmt.Errorf("app %s: %w", id, ErrNotFound)
	}
	if err != nil {
		return a, fmt.Errorf("get app: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) Create(ctx context.Context, app model.App) (model.App, error) {
	var a model.App
	err := s.pool.QueryRow(ctx, `
		INSERT INTO apps (id, name, version, author, description, icon_url, package_url, size_bytes, category, icon, color)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, name, version, author, description, icon_url, package_url,
		          size_bytes, category, icon, color, created_at, updated_at`,
		app.ID, app.Name, app.Version, app.Author, app.Description,
		app.IconURL, app.PackageURL, app.SizeBytes, app.Category,
		app.Icon, app.Color).Scan(
		&a.ID, &a.Name, &a.Version, &a.Author, &a.Description,
		&a.IconURL, &a.PackageURL, &a.SizeBytes, &a.Category,
		&a.Icon, &a.Color,
		&a.CreatedAt, &a.UpdatedAt)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == pgerrcode.UniqueViolation {
			return a, fmt.Errorf("app %s: %w", app.ID, ErrConflict)
		}
		return a, fmt.Errorf("create app: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) Update(ctx context.Context, id string, app model.App) (model.App, error) {
	var a model.App
	err := s.pool.QueryRow(ctx, `
		UPDATE apps SET name=$2, version=$3, author=$4, description=$5,
		       icon_url=$6, package_url=$7, size_bytes=$8, category=$9,
		       icon=$10, color=$11, updated_at=now()
		WHERE id=$1
		RETURNING id, name, version, author, description, icon_url, package_url,
		          size_bytes, category, icon, color, created_at, updated_at`,
		id, app.Name, app.Version, app.Author, app.Description,
		app.IconURL, app.PackageURL, app.SizeBytes, app.Category,
		app.Icon, app.Color).Scan(
		&a.ID, &a.Name, &a.Version, &a.Author, &a.Description,
		&a.IconURL, &a.PackageURL, &a.SizeBytes, &a.Category,
		&a.Icon, &a.Color,
		&a.CreatedAt, &a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return a, fmt.Errorf("app %s: %w", id, ErrNotFound)
	}
	if err != nil {
		return a, fmt.Errorf("update app: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) Delete(ctx context.Context, id string) error {
	tag, err := s.pool.Exec(ctx, `DELETE FROM apps WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("delete app: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("app %s: %w", id, ErrNotFound)
	}
	return nil
}

func (s *PostgresStore) CatalogHash(ctx context.Context) (string, error) {
	var hash *string
	err := s.pool.QueryRow(ctx, `
		SELECT md5(COALESCE(string_agg(
			id || name || version || author || description ||
			icon_url || package_url || size_bytes::text || category ||
			icon || color,
			'|' ORDER BY id
		), ''))
		FROM apps`).Scan(&hash)
	if err != nil {
		return "", fmt.Errorf("catalog hash: %w", err)
	}
	if hash == nil {
		return "empty", nil
	}
	return *hash, nil
}

func (s *PostgresStore) ListSecrets(ctx context.Context, appId string) ([]model.Secret, error) {
	rows, err := s.pool.Query(ctx,
		`SELECT key, encrypted_value FROM app_secrets WHERE app_id = $1 ORDER BY key`, appId)
	if err != nil {
		return nil, fmt.Errorf("list secrets: %w", err)
	}
	defer rows.Close()

	var secrets []model.Secret
	for rows.Next() {
		var key string
		var encVal []byte
		if err := rows.Scan(&key, &encVal); err != nil {
			return nil, fmt.Errorf("scan secret: %w", err)
		}
		plaintext, err := crypto.Decrypt(encVal, s.secretsKey)
		if err != nil {
			return nil, fmt.Errorf("decrypt secret %q: %w", key, err)
		}
		secrets = append(secrets, model.Secret{Key: key, Value: string(plaintext)})
	}
	if secrets == nil {
		secrets = []model.Secret{}
	}
	return secrets, rows.Err()
}

func (s *PostgresStore) SetSecrets(ctx context.Context, appId string, secrets []model.Secret) error {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	if _, err := tx.Exec(ctx, `DELETE FROM app_secrets WHERE app_id = $1`, appId); err != nil {
		return fmt.Errorf("delete old secrets: %w", err)
	}

	for _, secret := range secrets {
		encVal, err := crypto.Encrypt([]byte(secret.Value), s.secretsKey)
		if err != nil {
			return fmt.Errorf("encrypt secret %q: %w", secret.Key, err)
		}
		if _, err := tx.Exec(ctx,
			`INSERT INTO app_secrets (app_id, key, encrypted_value) VALUES ($1, $2, $3)`,
			appId, secret.Key, encVal); err != nil {
			return fmt.Errorf("insert secret %q: %w", secret.Key, err)
		}
	}

	return tx.Commit(ctx)
}
