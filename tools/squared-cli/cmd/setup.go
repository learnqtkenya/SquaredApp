package cmd

import (
	"archive/tar"
	"archive/zip"
	"bytes"
	"compress/gzip"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"squared-cli/internal/sdk"
)

func RunSetup(force bool) error {
	// Install SDK (QML type stubs for IDE autocomplete)
	if !force && sdk.IsInstalled() {
		sdkDir, _ := sdk.Dir()
		fmt.Printf("SDK already installed at %s\n", sdkDir)
	} else {
		fmt.Println("Installing Squared SDK...")
		sdkDir, err := sdk.Install(true)
		if err != nil {
			return fmt.Errorf("SDK install failed: %w", err)
		}
		fmt.Printf("Installed Squared SDK to %s\n", sdkDir)
	}

	// Install host app (needed for `squared run` and standalone use)
	sqDir, err := squaredDir()
	if err != nil {
		return err
	}
	binDir := filepath.Join(sqDir, "bin")
	if !force {
		for _, name := range hostBinaryNames() {
			p := filepath.Join(binDir, name)
			if _, err := os.Stat(p); err == nil {
				fmt.Printf("Host app already installed at %s\n", p)
				fmt.Println("\nUse --force to reinstall.")
				return nil
			}
		}
	}

	fmt.Println("Downloading Squared host app...")
	if err := downloadHostBinary(sqDir); err != nil {
		fmt.Fprintf(os.Stderr, "Warning: could not download host app: %v\n", err)
		fmt.Fprintln(os.Stderr, "You can build from source instead:")
		fmt.Fprintln(os.Stderr, "  git clone https://github.com/learnqtkenya/SquaredApp")
		fmt.Fprintln(os.Stderr, "  cd SquaredApp && cmake -G Ninja -B build && cmake --build build")
		return nil
	}
	fmt.Printf("Installed host app to %s\n", sqDir)

	fmt.Println()
	fmt.Println("Setup complete! You can now:")
	fmt.Println("  squared init my-app    # scaffold a new app")
	fmt.Println("  squared run my-app     # preview in host app")
	return nil
}

// hostBinaryNames returns the possible binary names for the current platform.
func hostBinaryNames() []string {
	switch runtime.GOOS {
	case "windows":
		return []string{"Squared.exe"}
	case "darwin":
		return []string{"Squared.app"}
	default:
		return []string{"Squared"}
	}
}

func squaredDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("cannot determine home directory: %w", err)
	}
	return filepath.Join(home, ".squared"), nil
}

func downloadHostBinary(destDir string) error {
	releases, err := fetchReleases()
	if err != nil {
		return fmt.Errorf("checking releases: %w", err)
	}

	// Find latest host release (tagged as host-v*)
	var tag string
	for _, r := range releases {
		if strings.HasPrefix(r.TagName, "host-v") {
			tag = r.TagName
			break
		}
	}
	if tag == "" {
		return fmt.Errorf("no host binary release found — build from source instead")
	}

	goos := runtime.GOOS
	goarch := runtime.GOARCH

	// Windows uses .zip, others use .tar.gz
	ext := "tar.gz"
	if goos == "windows" {
		ext = "zip"
	}

	archive := fmt.Sprintf("squared-host_%s_%s.%s", goos, goarch, ext)
	url := fmt.Sprintf("https://github.com/%s/releases/download/%s/%s", repo, tag, archive)

	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("download: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return fmt.Errorf("no host binary available for %s/%s (HTTP %d)", goos, goarch, resp.StatusCode)
	}

	if err := os.MkdirAll(destDir, 0o755); err != nil {
		return fmt.Errorf("creating bin directory: %w", err)
	}

	if goos == "windows" {
		return extractZip(resp.Body, destDir)
	}
	return extractTarGz(resp.Body, destDir)
}

func extractTarGz(r io.Reader, destDir string) error {
	gz, err := gzip.NewReader(r)
	if err != nil {
		return fmt.Errorf("decompressing: %w", err)
	}
	defer gz.Close()

	tr := tar.NewReader(gz)
	for {
		hdr, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return fmt.Errorf("reading archive: %w", err)
		}

		dst := filepath.Join(destDir, hdr.Name)

		switch hdr.Typeflag {
		case tar.TypeDir:
			if err := os.MkdirAll(dst, 0o755); err != nil {
				return fmt.Errorf("creating dir %s: %w", dst, err)
			}
		default:
			if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
				return fmt.Errorf("creating parent dir: %w", err)
			}
			data, err := io.ReadAll(tr)
			if err != nil {
				return fmt.Errorf("extracting %s: %w", hdr.Name, err)
			}
			if err := os.WriteFile(dst, data, 0o755); err != nil {
				return fmt.Errorf("writing %s: %w", dst, err)
			}
		}
	}
	return nil
}

func extractZip(r io.Reader, destDir string) error {
	data, err := io.ReadAll(r)
	if err != nil {
		return fmt.Errorf("reading zip: %w", err)
	}

	zr, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return fmt.Errorf("opening zip: %w", err)
	}

	for _, f := range zr.File {
		dst := filepath.Join(destDir, f.Name)

		if f.FileInfo().IsDir() {
			if err := os.MkdirAll(dst, 0o755); err != nil {
				return fmt.Errorf("creating dir %s: %w", dst, err)
			}
			continue
		}

		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return fmt.Errorf("creating parent dir: %w", err)
		}

		rc, err := f.Open()
		if err != nil {
			return fmt.Errorf("opening %s: %w", f.Name, err)
		}

		contents, err := io.ReadAll(rc)
		rc.Close()
		if err != nil {
			return fmt.Errorf("reading %s: %w", f.Name, err)
		}

		if err := os.WriteFile(dst, contents, 0o755); err != nil {
			return fmt.Errorf("writing %s: %w", dst, err)
		}
	}
	return nil
}
