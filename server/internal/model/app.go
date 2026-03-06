package model

import (
	"errors"
	"strings"
	"time"
)

type App struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Version     string    `json:"version"`
	Author      string    `json:"author"`
	Description string    `json:"description"`
	IconURL     string    `json:"iconUrl"`
	PackageURL  string    `json:"packageUrl"`
	SizeBytes   int64     `json:"sizeBytes"`
	Category    string    `json:"category"`
	Icon        string    `json:"icon"`
	Color       string    `json:"color"`
	CreatedAt   time.Time `json:"-"`
	UpdatedAt   time.Time `json:"-"`
}

type CatalogResponse struct {
	Apps []App `json:"apps"`
}

type ErrorResponse struct {
	Error     string `json:"error"`
	RequestID string `json:"requestId,omitempty"`
}

type Secret struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

type SecretsRequest struct {
	Secrets []Secret `json:"secrets"`
}

func (a *App) Validate() error {
	if a.ID == "" {
		return errors.New("id is required")
	}
	if a.Name == "" {
		return errors.New("name is required")
	}
	parts := strings.Split(a.ID, ".")
	if len(parts) < 2 {
		return errors.New("id must be in reverse domain format (e.g., com.example.app)")
	}
	return nil
}
