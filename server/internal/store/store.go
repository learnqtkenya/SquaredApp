package store

import (
	"context"

	"squared-store/internal/model"
)

type AppStore interface {
	List(ctx context.Context) ([]model.App, error)
	GetByID(ctx context.Context, id string) (model.App, error)
	Create(ctx context.Context, app model.App) (model.App, error)
	Update(ctx context.Context, id string, app model.App) (model.App, error)
	Delete(ctx context.Context, id string) error
	CatalogHash(ctx context.Context) (string, error)
	ListSecrets(ctx context.Context, appId string) ([]model.Secret, error)
	SetSecrets(ctx context.Context, appId string, secrets []model.Secret) error
}
