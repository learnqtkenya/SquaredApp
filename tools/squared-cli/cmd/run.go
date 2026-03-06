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

	// Check ~/.squared/bin/ (symlink from source build or downloaded binary)
	home, err := os.UserHomeDir()
	if err == nil {
		binDir := filepath.Join(home, ".squared", "bin")
		for _, name := range hostBinaryNames() {
			c := filepath.Join(binDir, name)
			if _, err := os.Stat(c); err == nil {
				// macOS .app bundle: launch the binary inside
				if filepath.Ext(c) == ".app" {
					return filepath.Join(c, "Contents", "MacOS", "Squared"), nil
				}
				return c, nil
			}
		}
	}

	return "", fmt.Errorf("Squared host binary not found.\n\n" +
		"Run 'squared setup' to download it, or build from source:\n" +
		"  git clone https://github.com/learnqtkenya/SquaredApp\n" +
		"  cd SquaredApp && cmake -G Ninja -B build && cmake --build build")
}
