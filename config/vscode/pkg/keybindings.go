package vscode

import (
	"os"
)

type BindingFile struct {
	file *os.File

	Comments    []string // Non-JSON field for comments
	KeyBindings          // Mixed JSON and Comment fields
}

func (b *BindingFile) MarshalJSONCIndent(prefix, indent string) ([]byte, error) {
	comments := commentString(b.Comments, prefix)
	// Marshal the keybindings with indentation
	keybindings, err := b.KeyBindings.MarshalJSONCIndent(prefix, indent)
	if err != nil {
		return nil, err
	}
	return append([]byte(comments), keybindings...), nil
}

type KeyBindings []Keybinding

func (k KeyBindings) Len() int {
	return len(k)
}

func (k KeyBindings) Contains(key, when string) bool {
	key = normalizeKey(key)
	for _, b := range k {
		if normalizeKey(b.Key) == key && b.When == when {
			return true
		}
	}
	return false
}

func (k KeyBindings) ByCommand(command string) *Keybinding {
	for _, binding := range k {
		if binding.Command == command {
			return &binding
		}
	}
	return nil
}

func (k KeyBindings) ByKey(key string) *Keybinding {
	for _, binding := range k {
		if binding.Key == key {
			return &binding
		}
	}
	return nil
}

func (k KeyBindings) MarshalJSONCIndent(prefix, indent string) ([]byte, error) {
	var result []byte
	for i, binding := range k {
		data, err := binding.MarshalJSONCIndent(prefix+indent, indent)
		if err != nil {
			return nil, err
		}
		if len(binding.comments) > 0 {
			result = append(result, []byte("\n")...) // separate commented keybindings visually
		}
		result = append(result, data...)
		if i < len(k)-1 {
			result = append(result, []byte(",\n")...)
		}
	}
	if len(result) == 0 {
		return nil, nil
	}
	start := []byte(prefix + "[\n")
	end := []byte(prefix + "\n]\n")
	return append(append(start, result...), end...), nil
}
