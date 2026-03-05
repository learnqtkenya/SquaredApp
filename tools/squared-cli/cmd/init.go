package cmd

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"unicode"

	"squared-cli/internal/manifest"
)

var validName = regexp.MustCompile(`^[a-zA-Z][a-zA-Z0-9._-]*$`)

// RunInit scaffolds a new Squared app project in a directory named after name.
func RunInit(name string) error {
	if !validName.MatchString(name) {
		return fmt.Errorf("invalid project name %q: must start with a letter and contain only letters, digits, dots, hyphens, or underscores", name)
	}

	if _, err := os.Stat(name); err == nil {
		return fmt.Errorf("directory %q already exists", name)
	}

	displayName := titleCase(name)
	id := "com.developer." + alphaOnly(name)

	m := manifest.Manifest{
		ID:      id,
		Name:    displayName,
		Version: "1.0.0",
		Entry:   "Main.qml",
		Icon:    "assets/icon.png",
	}

	for _, d := range []string{filepath.Join(name, "qml"), filepath.Join(name, "assets")} {
		if err := os.MkdirAll(d, 0o755); err != nil {
			return fmt.Errorf("creating %s: %w", d, err)
		}
	}

	data, err := json.MarshalIndent(m, "", "    ")
	if err != nil {
		return fmt.Errorf("encoding manifest: %w", err)
	}
	if err := os.WriteFile(filepath.Join(name, "manifest.json"), append(data, '\n'), 0o644); err != nil {
		return fmt.Errorf("writing manifest.json: %w", err)
	}

	qml := fmt.Sprintf(`import QtQuick
import QtQuick.Layouts
import Squared.UI

SPage {
    title: "%s"

    SEmptyState {
        title: "Welcome to %s"
        description: "Edit qml/Main.qml to get started"
        icon: IconCodes.rocketLaunch
    }
}
`, displayName, displayName)

	if err := os.WriteFile(filepath.Join(name, "qml", "Main.qml"), []byte(qml), 0o644); err != nil {
		return fmt.Errorf("writing Main.qml: %w", err)
	}

	fmt.Printf("Created %s/\n", name)
	return nil
}

func titleCase(s string) string {
	words := strings.FieldsFunc(s, func(c rune) bool { return c == '-' || c == '_' || c == '.' })
	for i, w := range words {
		r := []rune(w)
		r[0] = unicode.ToUpper(r[0])
		words[i] = string(r)
	}
	return strings.Join(words, " ")
}

func alphaOnly(s string) string {
	var b strings.Builder
	for _, r := range strings.ToLower(s) {
		if r >= 'a' && r <= 'z' || r >= '0' && r <= '9' {
			b.WriteRune(r)
		}
	}
	return b.String()
}
