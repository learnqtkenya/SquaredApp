package packager_test

import (
	"archive/zip"
	"os"
	"path/filepath"
	"testing"

	"squared-cli/internal/packager"
)

func setupApp(t *testing.T, dir string) {
	t.Helper()
	for _, d := range []string{"qml", "assets"} {
		os.MkdirAll(filepath.Join(dir, d), 0o755)
	}
	os.WriteFile(filepath.Join(dir, "manifest.json"), []byte(`{
		"id": "com.test.app",
		"name": "Test App",
		"version": "1.0.0",
		"author": "Test",
		"description": "A test"
	}`), 0o644)
	os.WriteFile(filepath.Join(dir, "qml", "Main.qml"), []byte("import QtQuick\nItem {}"), 0o644)
	os.WriteFile(filepath.Join(dir, "assets", "icon.png"), []byte("fake-png"), 0o644)
}

func zipEntries(t *testing.T, path string) map[string]bool {
	t.Helper()
	r, err := zip.OpenReader(path)
	if err != nil {
		t.Fatalf("opening zip: %v", err)
	}
	defer r.Close()
	entries := make(map[string]bool)
	for _, f := range r.File {
		entries[f.Name] = true
	}
	return entries
}

func TestPackageContainsExpectedFiles(t *testing.T) {
	root := t.TempDir()
	appDir := filepath.Join(root, "myapp")
	setupApp(t, appDir)

	out := filepath.Join(root, "out.sqapp")
	got, err := packager.Package(appDir, out)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got != out {
		t.Errorf("returned path = %q, want %q", got, out)
	}

	entries := zipEntries(t, out)
	for _, want := range []string{"manifest.json", "qml/Main.qml", "assets/icon.png"} {
		if !entries[want] {
			t.Errorf("missing entry: %s", want)
		}
	}
}

func TestPackageDefaultOutputName(t *testing.T) {
	root := t.TempDir()
	appDir := filepath.Join(root, "myapp")
	setupApp(t, appDir)

	got, err := packager.Package(appDir, "")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	want := filepath.Join(appDir, "com.test.app-1.0.0.sqapp")
	if got != want {
		t.Errorf("output = %q, want %q", got, want)
	}
}

func TestPackageExcludesHiddenAndBuild(t *testing.T) {
	root := t.TempDir()
	appDir := filepath.Join(root, "myapp")
	setupApp(t, appDir)

	os.WriteFile(filepath.Join(appDir, ".hidden"), []byte("x"), 0o644)
	os.MkdirAll(filepath.Join(appDir, ".git", "objects"), 0o755)
	os.WriteFile(filepath.Join(appDir, ".git", "config"), []byte("x"), 0o644)
	os.MkdirAll(filepath.Join(appDir, "build"), 0o755)
	os.WriteFile(filepath.Join(appDir, "build", "output"), []byte("x"), 0o644)
	os.WriteFile(filepath.Join(appDir, "qml", "cache.pyc"), []byte("x"), 0o644)

	out := filepath.Join(root, "out.sqapp")
	_, err := packager.Package(appDir, out)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	entries := zipEntries(t, out)
	for _, excluded := range []string{".hidden", ".git/config", "build/output", "qml/cache.pyc"} {
		if entries[excluded] {
			t.Errorf("should not contain: %s", excluded)
		}
	}
}

func TestPackageMissingManifest(t *testing.T) {
	_, err := packager.Package(t.TempDir(), filepath.Join(t.TempDir(), "out.sqapp"))
	if err == nil {
		t.Fatal("expected error for missing manifest")
	}
}

func TestPackageInvalidManifest(t *testing.T) {
	dir := t.TempDir()
	os.WriteFile(filepath.Join(dir, "manifest.json"), []byte(`{"name":"T"}`), 0o644)
	_, err := packager.Package(dir, filepath.Join(dir, "out.sqapp"))
	if err == nil {
		t.Fatal("expected error for invalid manifest")
	}
}
