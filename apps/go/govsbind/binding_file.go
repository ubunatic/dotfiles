package vscode

import "os"

type BindingFile struct {
	file *os.File

	Comments    []string // Non-JSON field for comments
	KeyBindings          // Mixed JSON and Comment fields
}

func (b *BindingFile) Marshal(prefix, indent string) ([]byte, error) {
	comments := commentString(b.Comments, prefix)
	// Marshal the keybindings with indentation
	keybindings, err := marshalKeybindings(b.KeyBindings, prefix, indent)
	if err != nil {
		return nil, err
	}
	return append([]byte(comments), keybindings...), nil
}
