package vscode

import "strings"

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

func normalizeKey(key string) string {
	return strings.ToLower(strings.TrimSpace(key))
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
