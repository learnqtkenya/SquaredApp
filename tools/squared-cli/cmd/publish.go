package cmd

import (
	"archive/zip"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"squared-cli/internal/manifest"
)

// publishRequest is the JSON body sent to POST /api/apps.
type publishRequest struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Version     string `json:"version"`
	Author      string `json:"author,omitempty"`
	Description string `json:"description,omitempty"`
	PackageURL  string `json:"packageUrl,omitempty"`
}

// RunPublish reads a .sqapp archive and publishes its metadata to a store server.
func RunPublish(ctx context.Context, sqappPath, serverURL, token, packageURL string) error {
	if sqappPath == "" {
		return fmt.Errorf("sqapp file path is required")
	}

	if serverURL == "" {
		serverURL = os.Getenv("SQUARED_SERVER_URL")
	}
	if serverURL == "" {
		serverURL = "http://localhost:8080"
	}

	if token == "" {
		token = os.Getenv("SQUARED_TOKEN")
	}

	m, err := readManifestFromZip(sqappPath)
	if err != nil {
		return fmt.Errorf("reading manifest from %s: %w", sqappPath, err)
	}

	body := publishRequest{
		ID:          m.ID,
		Name:        m.Name,
		Version:     m.Version,
		Author:      m.Author,
		Description: m.Description,
		PackageURL:  packageURL,
	}

	data, err := json.Marshal(body)
	if err != nil {
		return fmt.Errorf("encoding request: %w", err)
	}

	url := serverURL + "/api/apps"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(data))
	if err != nil {
		return fmt.Errorf("creating request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("request to %s: %w", url, err)
	}
	defer resp.Body.Close()

	switch resp.StatusCode {
	case http.StatusCreated:
		fmt.Printf("Published %s v%s to %s\n", m.Name, m.Version, serverURL)
		return nil
	case http.StatusConflict:
		return fmt.Errorf("%s v%s already exists on %s", m.ID, m.Version, serverURL)
	default:
		respBody, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("server returned %d: %s", resp.StatusCode, bytes.TrimSpace(respBody))
	}
}

func readManifestFromZip(path string) (manifest.Manifest, error) {
	r, err := zip.OpenReader(path)
	if err != nil {
		return manifest.Manifest{}, fmt.Errorf("opening archive: %w", err)
	}
	defer r.Close()

	for _, f := range r.File {
		if f.Name != "manifest.json" {
			continue
		}
		rc, err := f.Open()
		if err != nil {
			return manifest.Manifest{}, err
		}
		defer rc.Close()

		data, err := io.ReadAll(rc)
		if err != nil {
			return manifest.Manifest{}, err
		}
		return manifest.Parse(data)
	}

	return manifest.Manifest{}, fmt.Errorf("manifest.json not found in archive")
}
