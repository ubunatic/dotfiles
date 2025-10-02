package dconf

import (
	"fmt"
	"log/slog"
	"os"
	"slices"
)

func Main(commands []string, dry bool) error {

	// Read all configured keybindings paths /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-my-binding/
	configuredNames, err := ReadList(KeyCustomKeybindingsList, "name")
	if err != nil {
		return err
	}

	slog.Info("Found configured custom keybindings", "names", configuredNames)

	configured, err := ReadList(KeyCustomKeybindingsList, "")
	if err != nil {
		return err
	}

	for i, name := range configured {
		configured[i] = KeyCustomKeybindingsList + name
	}

	// Read current enabled keybindings
	entries, err := ReadArray(KeyCustomKeybindings)
	if err != nil {
		return err
	}

	ShowEntries("Current enabled entries:", entries)

	for _, cmd := range commands {
		switch cmd {
		case "dry":
			// Ignore
		case "update-keybindings":
			// Enable all configured keybindings
			fmt.Println("Enabling all configured keybindings...")

			slices.Sort(configured)
			slices.Sort(entries)

			if slices.Equal(configured, entries) {
				slog.Info("All configured keybindings are already enabled, nothing to do.")
				continue
			} else {
				slog.Info("Updating enabled keybindings", "from", entries, "to", configured)
				entries = configured
			}
			WriteArray(KeyCustomKeybindings, entries, dry)
		case "disable-custom-keybindings":
			slog.Info("Disabling all custom keybindings (excl. named like custom0, custom1, ...)...")
			var filtered []string
			for _, entry := range entries {
				if KeyCustomRe.MatchString(entry) {
					filtered = append(filtered, entry)
				} else {
					slog.Info("Removing custom keybinding", "entry", entry)
				}
			}
			if len(filtered) == len(entries) {
				fmt.Println("No custom keybindings to disable.")
				continue
			}
			entries = filtered
			WriteArray(KeyCustomKeybindings, entries, dry)
		default:
			fmt.Fprintf(os.Stderr, "Unknown command: %q\n", cmd)
			os.Exit(1)
		}
	}

	// Verify
	entries, err = ReadArray(KeyCustomKeybindings)
	if err != nil {
		return err
	}
	ShowEntries("New entries:", entries)
	return nil
}
