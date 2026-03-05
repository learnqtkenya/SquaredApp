package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// RunRun launches the app at the given path in the Squared host app's dev mode.
func RunRun(appPath string) error {
	if appPath == "" {
		appPath = "."
	}

	abs, err := filepath.Abs(appPath)
	if err != nil {
		return fmt.Errorf("resolving path: %w", err)
	}

	// Verify manifest.json exists
	if _, err := os.Stat(filepath.Join(abs, "manifest.json")); err != nil {
		return fmt.Errorf("no manifest.json found in %s — is this a Squared app?", abs)
	}

	// Find the Squared host binary
	hostBin, err := findHostBinary()
	if err != nil {
		return err
	}

	cmd := exec.Command(hostBin, "--dev", abs)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	fmt.Printf("Running %s in dev mode...\n", filepath.Base(abs))
	return cmd.Run()
}

func findHostBinary() (string, error) {
	// Check PATH first
	if p, err := exec.LookPath("Squared"); err == nil {
		return p, nil
	}

	// Check common build locations relative to SDK install
	home, err := os.UserHomeDir()
	if err == nil {
		candidates := []string{
			filepath.Join(home, ".squared", "bin", "Squared"),
		}
		for _, c := range candidates {
			if _, err := os.Stat(c); err == nil {
				return c, nil
			}
		}
	}

	return "", fmt.Errorf("Squared host binary not found.\n\n" +
		"To use 'squared run', the Squared host app must be built and accessible.\n" +
		"Either:\n" +
		"  1. Add the build directory to PATH: export PATH=/path/to/build/src:$PATH\n" +
		"  2. Copy the binary: cp /path/to/build/src/Squared ~/.squared/bin/")
}
