package manifest_test

import (
	"os"
	"path/filepath"
	"testing"

	"squared-cli/internal/manifest"
)

func writeFile(t *testing.T, dir, name, content string) {
	t.Helper()
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, name), []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
}

func TestParse(t *testing.T) {
	tests := []struct {
		name    string
		json    string
		wantErr bool
		checkFn func(t *testing.T, m manifest.Manifest)
	}{
		{
			name: "valid full manifest",
			json: `{"id":"com.example.test","name":"Test","version":"1.0.0","author":"A","description":"D"}`,
			checkFn: func(t *testing.T, m manifest.Manifest) {
				if m.ID != "com.example.test" {
					t.Errorf("ID = %q", m.ID)
				}
				if m.Entry != "Main.qml" {
					t.Errorf("Entry = %q, want default Main.qml", m.Entry)
				}
			},
		},
		{
			name: "custom entry preserved",
			json: `{"id":"com.example.test","name":"Test","version":"1.0.0","entry":"App.qml"}`,
			checkFn: func(t *testing.T, m manifest.Manifest) {
				if m.Entry != "App.qml" {
					t.Errorf("Entry = %q, want App.qml", m.Entry)
				}
			},
		},
		{name: "missing id", json: `{"name":"T","version":"1.0.0"}`, wantErr: true},
		{name: "missing name", json: `{"id":"com.example.t","version":"1.0.0"}`, wantErr: true},
		{name: "missing version", json: `{"id":"com.example.t","name":"T"}`, wantErr: true},
		{name: "single-segment id", json: `{"id":"nope","name":"T","version":"1.0.0"}`, wantErr: true},
		{name: "id with empty segment", json: `{"id":"com..test","name":"T","version":"1.0.0"}`, wantErr: true},
		{name: "id starting with digit", json: `{"id":"1com.test","name":"T","version":"1.0.0"}`, wantErr: true},
		{name: "id with special chars", json: `{"id":"com.ex@mple.test","name":"T","version":"1.0.0"}`, wantErr: true},
		{name: "invalid json", json: `{not json}`, wantErr: true},
		{name: "empty object", json: `{}`, wantErr: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			m, err := manifest.Parse([]byte(tt.json))
			if tt.wantErr {
				if err == nil {
					t.Fatal("expected error, got nil")
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if tt.checkFn != nil {
				tt.checkFn(t, m)
			}
		})
	}
}

func TestLoadDir(t *testing.T) {
	dir := t.TempDir()
	writeFile(t, dir, "manifest.json", `{"id":"com.example.app","name":"App","version":"1.0.0"}`)

	m, err := manifest.LoadDir(dir)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if m.ID != "com.example.app" {
		t.Errorf("ID = %q", m.ID)
	}
}

func TestLoadDirMissing(t *testing.T) {
	_, err := manifest.LoadDir(t.TempDir())
	if err == nil {
		t.Fatal("expected error for missing manifest.json")
	}
}

func TestOutputName(t *testing.T) {
	m := manifest.Manifest{ID: "com.example.app", Version: "2.1.0"}
	want := "com.example.app-2.1.0.sqapp"
	if got := m.OutputName(); got != want {
		t.Errorf("OutputName() = %q, want %q", got, want)
	}
}

func TestWarnings(t *testing.T) {
	m := manifest.Manifest{ID: "com.example.test", Name: "Test", Version: "1.0.0"}
	if w := m.Warnings(); len(w) != 2 {
		t.Fatalf("expected 2 warnings, got %d", len(w))
	}

	m.Author = "Author"
	m.Description = "Desc"
	if w := m.Warnings(); len(w) != 0 {
		t.Fatalf("expected 0 warnings, got %d: %v", len(w), w)
	}
}
