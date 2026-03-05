package main

import (
	"context"
	"flag"
	"fmt"
	"os"

	"squared-cli/cmd"
)

var version = "dev"

const usage = `squared — Squared app developer CLI

Usage:
  squared init <name>
  squared validate [path]
  squared package [path] [--output <file>]
  squared publish <sqapp> [--server <url>] [--token <token>] [--package-url <url>]
  squared run [path]
  squared update
  squared version
  squared help
`

func main() {
	if len(os.Args) < 2 {
		fmt.Print(usage)
		os.Exit(0)
	}

	var err error
	switch os.Args[1] {
	case "init":
		err = runInit(os.Args[2:])
	case "validate":
		code := runValidate(os.Args[2:])
		os.Exit(code)
	case "package":
		err = runPackage(os.Args[2:])
	case "publish":
		err = runPublish(os.Args[2:])
	case "run":
		runRun()
	case "update":
		err = cmd.RunUpdate(version)
	case "version", "--version", "-v":
		fmt.Printf("squared %s\n", version)
		os.Exit(0)
	case "help", "--help", "-h":
		fmt.Print(usage)
		os.Exit(0)
	default:
		fmt.Fprintf(os.Stderr, "unknown command: %s\n\n%s", os.Args[1], usage)
		os.Exit(1)
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func runInit(args []string) error {
	fs := flag.NewFlagSet("init", flag.ContinueOnError)
	if err := fs.Parse(args); err != nil {
		return err
	}
	if fs.NArg() != 1 {
		return fmt.Errorf("usage: squared init <name>")
	}
	return cmd.RunInit(fs.Arg(0))
}

func runValidate(args []string) int {
	fs := flag.NewFlagSet("validate", flag.ContinueOnError)
	if err := fs.Parse(args); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		return cmd.ExitError
	}
	path := fs.Arg(0)
	return cmd.RunValidate(path)
}

func runPackage(args []string) error {
	fs := flag.NewFlagSet("package", flag.ContinueOnError)
	output := fs.String("output", "", "output file path")
	if err := fs.Parse(args); err != nil {
		return err
	}
	return cmd.RunPackage(fs.Arg(0), *output)
}

func runPublish(args []string) error {
	fs := flag.NewFlagSet("publish", flag.ContinueOnError)
	server := fs.String("server", "", "store server URL (default: $SQUARED_SERVER_URL or http://localhost:8080)")
	token := fs.String("token", "", "auth token (default: $SQUARED_TOKEN)")
	packageURL := fs.String("package-url", "", "download URL for the .sqapp package")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if fs.NArg() != 1 {
		return fmt.Errorf("usage: squared publish <sqapp> [--server <url>] [--token <token>] [--package-url <url>]")
	}
	ctx := context.Background()
	return cmd.RunPublish(ctx, fs.Arg(0), *server, *token, *packageURL)
}

func runRun() {
	fmt.Println("The 'run' command is not yet implemented.")
	fmt.Println("To preview your app, build and run the Squared host app:")
	fmt.Println("  1. Copy your app to examples/apps/<name>/")
	fmt.Println("  2. cmake --build build && ./build/src/Squared")
	os.Exit(0)
}
