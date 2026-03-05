package packager

import (
	"archive/zip"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"squared-cli/internal/manifest"
)

// excludedDirs are directory names that should never be included in a package.
var excludedDirs = map[string]bool{
	".git":         true,
	"__pycache__":  true,
	"build":        true,
	"node_modules": true,
}

// excludedExts are file extensions to exclude.
var excludedExts = map[string]bool{
	".pyc":   true,
	".sqapp": true,
}

func isExcluded(name string, isDir bool) bool {
	if strings.HasPrefix(name, ".") {
		return true
	}
	if isDir {
		return excludedDirs[name]
	}
	return excludedExts[filepath.Ext(name)]
}

// Package creates a .sqapp ZIP from appDir. If outputPath is empty, the
// default <id>-<version>.sqapp name is used, placed alongside appDir.
// Returns the output path and any error.
func Package(appDir, outputPath string) (string, error) {
	m, err := manifest.LoadDir(appDir)
	if err != nil {
		return "", err
	}

	if outputPath == "" {
		outputPath = filepath.Join(appDir, m.OutputName())
	}

	f, err := os.Create(outputPath)
	if err != nil {
		return "", fmt.Errorf("creating output: %w", err)
	}

	zw := zip.NewWriter(f)
	var walkErr error

	walkErr = filepath.WalkDir(appDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		rel, err := filepath.Rel(appDir, path)
		if err != nil {
			return err
		}
		if rel == "." {
			return nil
		}

		name := d.Name()

		if d.IsDir() {
			if isExcluded(name, true) {
				return filepath.SkipDir
			}
			return nil
		}

		if isExcluded(name, false) {
			return nil
		}

		info, err := d.Info()
		if err != nil {
			return err
		}

		header, err := zip.FileInfoHeader(info)
		if err != nil {
			return err
		}
		header.Name = filepath.ToSlash(rel)
		header.Method = zip.Deflate

		w, err := zw.CreateHeader(header)
		if err != nil {
			return err
		}

		src, err := os.Open(path)
		if err != nil {
			return err
		}
		defer src.Close()

		_, err = io.Copy(w, src)
		return err
	})

	// Close zip writer first — this flushes the central directory.
	if closeErr := zw.Close(); closeErr != nil && walkErr == nil {
		walkErr = fmt.Errorf("finalizing archive: %w", closeErr)
	}

	// Close underlying file.
	if closeErr := f.Close(); closeErr != nil && walkErr == nil {
		walkErr = fmt.Errorf("closing output: %w", closeErr)
	}

	if walkErr != nil {
		os.Remove(outputPath)
		return "", walkErr
	}

	return outputPath, nil
}
