package cmd

import (
	"fmt"

	"squared-cli/internal/sdk"
)

func RunSetup(force bool) error {
	if !force && sdk.IsInstalled() {
		sdkDir, _ := sdk.Dir()
		fmt.Printf("SDK already installed at %s\n", sdkDir)
		fmt.Println("Use --force to reinstall.")
		return nil
	}

	fmt.Println("Installing Squared SDK...")

	sdkDir, err := sdk.Install(true)
	if err != nil {
		return fmt.Errorf("setup failed: %w", err)
	}

	fmt.Printf("Installed Squared SDK to %s\n", sdkDir)
	fmt.Println()
	fmt.Println("Your IDE will now provide autocomplete for Squared.UI components.")
	fmt.Println("Requires qmlls (Qt QML Language Server) — included with Qt 6.4+.")
	fmt.Println()
	fmt.Println("Supported editors:")
	fmt.Println("  - Qt Creator (built-in)")
	fmt.Println("  - VS Code (Qt QML extension)")
	fmt.Println("  - Neovim (via qmlls LSP)")
	return nil
}
