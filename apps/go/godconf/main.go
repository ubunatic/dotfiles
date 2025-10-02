package main

import (
	"fmt"
	"os"
	"slices"

	"ubunatic.com/dotapps/go/godconf/dconf"
	"ubunatic.com/dotapps/go/gololog"
)

func exitOnError(err error) {
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Println(`
Usage: godconf [options|commands...]

Commands:
	update-keybindings              Read the paths of configured keybindings and enabled them
	disable-custom-keybindings      Disable all custom keybindings (excl. named like custom0, custom1, ...)
	help						    Show this help message

Options:
	dry                   Do not write changes, just show what would be done
		`)
}

func main() {
	// App Logic:
	// 1. Read all custom configured keybindings /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/
	// 2. Read current enabled keybindings /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
	// 3. Enable all configured keybindings (if not already enabled)
	// 4. Optionally disable all custom keybindings (excl. named like custom0, custom1, ...)

	// Setup logging
	gololog.SetupColoredSlogLogging()

	// Simple command line parsing. All args are commands, flags are special words.
	var commands = os.Args[1:]
	if len(commands) == 0 {
		usage()
		os.Exit(1)
	}

	if slices.Contains(commands, "help") {
		usage()
		os.Exit(0)
	}

	dry := slices.Contains(commands, "dry")
	exitOnError(dconf.Main(commands, dry))
}
