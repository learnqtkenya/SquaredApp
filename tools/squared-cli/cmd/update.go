package cmd

import (
	"archive/tar"
	"compress/gzip"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"runtime"
	"strings"
)

const repo = "learnqtkenya/SquaredApp"

type ghRelease struct {
	TagName string `json:"tag_name"`
}

func RunUpdate(currentVersion string) error {
	fmt.Println("Checking for updates...")

	releases, err := fetchReleases()
	if err != nil {
		return fmt.Errorf("failed to check for updates: %w", err)
	}

	latest := ""
	for _, r := range releases {
		if strings.HasPrefix(r.TagName, "v") {
			latest = r.TagName
			break
		}
	}
	if latest == "" {
		return fmt.Errorf("no releases found")
	}

	latestVersion := latest
	if latestVersion == currentVersion || "v"+currentVersion == latestVersion {
		fmt.Printf("Already up to date (%s)\n", currentVersion)
		return nil
	}

	fmt.Printf("Updating %s -> %s\n", currentVersion, latestVersion)

	goos := runtime.GOOS
	goarch := runtime.GOARCH
	ext := "tar.gz"
	if goos == "windows" {
		ext = "zip"
	}

	archive := fmt.Sprintf("squared_%s_%s_%s.%s", strings.TrimPrefix(latestVersion, "v"), goos, goarch, ext)
	url := fmt.Sprintf("https://github.com/%s/releases/download/%s/%s", repo, latest, archive)

	exe, err := os.Executable()
	if err != nil {
		return fmt.Errorf("cannot determine executable path: %w", err)
	}

	if goos == "windows" {
		return fmt.Errorf("self-update on Windows is not supported — re-run: irm https://squared.co.ke/install.ps1 | iex")
	}

	binary, err := downloadAndExtract(url)
	if err != nil {
		return fmt.Errorf("download failed: %w", err)
	}

	// Atomic replace: rename old, write new, remove old
	backup := exe + ".bak"
	if err := os.Rename(exe, backup); err != nil {
		return fmt.Errorf("cannot replace binary: %w", err)
	}

	if err := os.WriteFile(exe, binary, 0755); err != nil {
		// Restore backup on failure
		os.Rename(backup, exe)
		return fmt.Errorf("cannot write new binary: %w", err)
	}

	os.Remove(backup)
	fmt.Printf("Updated to squared %s\n", latestVersion)
	return nil
}

func fetchReleases() ([]ghRelease, error) {
	resp, err := http.Get(fmt.Sprintf("https://api.github.com/repos/%s/releases", repo))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("GitHub API returned %d", resp.StatusCode)
	}

	var releases []ghRelease
	if err := json.NewDecoder(resp.Body).Decode(&releases); err != nil {
		return nil, err
	}
	return releases, nil
}

func downloadAndExtract(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("download returned %d", resp.StatusCode)
	}

	gz, err := gzip.NewReader(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("gzip error: %w", err)
	}
	defer gz.Close()

	tr := tar.NewReader(gz)
	for {
		hdr, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return nil, err
		}
		if hdr.Name == "squared" || strings.HasSuffix(hdr.Name, "/squared") {
			return io.ReadAll(tr)
		}
	}
	return nil, fmt.Errorf("binary not found in archive")
}
