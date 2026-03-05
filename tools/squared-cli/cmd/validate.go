package cmd

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"

	"squared-cli/internal/manifest"
)

// Exit codes for validation.
const (
	ExitOK       = 0
	ExitError    = 1
	ExitWarnings = 2
)

// RunValidate checks a Squared app directory for correctness.
// Returns an exit code: 0 = valid, 1 = errors, 2 = warnings only.
func RunValidate(path string) int {
	if path == "" {
		path = "."
	}

	m, err := manifest.LoadDir(path)
	if err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: %v\n", err)
		return ExitError
	}

	// Entry QML file must exist.
	entryPath := filepath.Join(path, "qml", m.Entry)
	if _, err := os.Stat(entryPath); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "ERROR: entry file not found: qml/%s\n", m.Entry)
		return ExitError
	}

	var warnings []string
	warnings = append(warnings, m.Warnings()...)

	if size, err := dirSize(path); err == nil && size > 5<<20 {
		warnings = append(warnings, fmt.Sprintf("total size %.1f MB exceeds 5 MB", float64(size)/(1<<20)))
	}

	for _, w := range warnings {
		fmt.Fprintf(os.Stderr, "WARN: %s\n", w)
	}

	if len(warnings) > 0 {
		fmt.Printf("Validated %s (%s v%s) — %d warning(s)\n", m.Name, m.ID, m.Version, len(warnings))
		return ExitWarnings
	}

	fmt.Printf("Validated %s (%s v%s)\n", m.Name, m.ID, m.Version)
	return ExitOK
}

func dirSize(root string) (int64, error) {
	var total int64
	err := filepath.WalkDir(root, func(_ string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() {
			if info, err := d.Info(); err == nil {
				total += info.Size()
			}
		}
		return nil
	})
	return total, err
}
