package manifest

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// idPattern matches valid reverse-domain identifiers like "com.example.app".
var idPattern = regexp.MustCompile(`^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)+$`)

// Manifest represents a parsed manifest.json for a Squared app.
type Manifest struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Version     string `json:"version"`
	Entry       string `json:"entry,omitempty"`
	Icon        string `json:"icon,omitempty"`
	Author      string `json:"author,omitempty"`
	Description string `json:"description,omitempty"`
}

// LoadDir reads and validates manifest.json from a directory.
func LoadDir(dir string) (Manifest, error) {
	data, err := os.ReadFile(filepath.Join(dir, "manifest.json"))
	if err != nil {
		return Manifest{}, fmt.Errorf("reading manifest.json: %w", err)
	}
	return Parse(data)
}

// Parse decodes JSON bytes into a Manifest, applies defaults, and validates.
func Parse(data []byte) (Manifest, error) {
	var m Manifest
	if err := json.Unmarshal(data, &m); err != nil {
		return Manifest{}, fmt.Errorf("parsing manifest.json: %w", err)
	}
	if m.Entry == "" {
		m.Entry = "Main.qml"
	}
	if err := m.Validate(); err != nil {
		return Manifest{}, err
	}
	return m, nil
}

// Validate checks required fields and ID format.
func (m Manifest) Validate() error {
	var errs []string
	if m.ID == "" {
		errs = append(errs, "missing required field \"id\"")
	} else if !idPattern.MatchString(m.ID) {
		errs = append(errs, fmt.Sprintf("id %q is not valid reverse-domain format (e.g., com.example.app)", m.ID))
	}
	if m.Name == "" {
		errs = append(errs, "missing required field \"name\"")
	}
	if m.Version == "" {
		errs = append(errs, "missing required field \"version\"")
	}
	if len(errs) > 0 {
		return fmt.Errorf("manifest: %s", strings.Join(errs, "; "))
	}
	return nil
}

// Warnings returns non-fatal issues (missing recommended fields).
func (m Manifest) Warnings() []string {
	var w []string
	if m.Author == "" {
		w = append(w, "missing recommended field \"author\"")
	}
	if m.Description == "" {
		w = append(w, "missing recommended field \"description\"")
	}
	return w
}

// OutputName returns the default package filename: <id>-<version>.sqapp.
func (m Manifest) OutputName() string {
	return m.ID + "-" + m.Version + ".sqapp"
}
