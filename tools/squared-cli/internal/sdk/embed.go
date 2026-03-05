package sdk

import (
	"embed"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

//go:generate sh -c "cd ../../../.. && ./sync-sdk.sh"

//go:embed all:files
var files embed.FS

// Install extracts the embedded SDK files to ~/.squared/sdk/.
// Returns the absolute path to the SDK directory.
func Install(force bool) (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("cannot determine home directory: %w", err)
	}

	sdkDir := filepath.Join(home, ".squared", "sdk")

	if !force {
		if _, err := os.Stat(filepath.Join(sdkDir, "CMakeLists.txt")); err == nil {
			return sdkDir, nil
		}
	}

	err = fs.WalkDir(files, "files", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Strip "files/" prefix to get relative output path
		rel, _ := filepath.Rel("files", path)
		dst := filepath.Join(sdkDir, rel)

		if d.IsDir() {
			return os.MkdirAll(dst, 0o755)
		}

		data, err := files.ReadFile(path)
		if err != nil {
			return fmt.Errorf("reading embedded %s: %w", path, err)
		}

		return os.WriteFile(dst, data, 0o644)
	})
	if err != nil {
		return "", fmt.Errorf("installing SDK: %w", err)
	}

	return sdkDir, nil
}

// Dir returns the SDK directory path without installing.
func Dir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".squared", "sdk"), nil
}

// IsInstalled checks if the SDK is already installed.
func IsInstalled() bool {
	home, err := os.UserHomeDir()
	if err != nil {
		return false
	}
	_, err = os.Stat(filepath.Join(home, ".squared", "sdk", "CMakeLists.txt"))
	return err == nil
}
