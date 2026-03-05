package cmd

import (
	"fmt"
	"os"

	"squared-cli/internal/packager"
)

// RunPackage validates and packages a Squared app directory into a .sqapp ZIP.
func RunPackage(path, output string) error {
	if path == "" {
		path = "."
	}

	if code := RunValidate(path); code == ExitError {
		return fmt.Errorf("validation failed; fix errors above before packaging")
	}

	outPath, err := packager.Package(path, output)
	if err != nil {
		return err
	}

	info, err := os.Stat(outPath)
	if err != nil {
		return err
	}

	fmt.Printf("Packaged %s (%s)\n", outPath, formatSize(info.Size()))
	return nil
}

func formatSize(b int64) string {
	switch {
	case b >= 1<<20:
		return fmt.Sprintf("%.1f MB", float64(b)/(1<<20))
	case b >= 1<<10:
		return fmt.Sprintf("%.1f KB", float64(b)/(1<<10))
	default:
		return fmt.Sprintf("%d B", b)
	}
}
