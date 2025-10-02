package vscode

import (
	"log/slog"
	"strings"
)

type Keybinding struct {
	comments []string // Non-JSON field for comments
	KeybindingEntry
}

type KeybindingEntry struct {
	Key     string `json:"key"`     // example: "ctrl+shift+-"
	Command string `json:"command"` // example: "workbench.action.navigateForward", disabled: "-workbench.action.navigateForward"
	When    string `json:"when"`    // example: "canNavigateForward"
}

func (kb Keybinding) IsDisabled() bool { return !strings.HasPrefix(kb.Command, "-") }

func (kb Keybinding) CommentString(prefix string) string {
	if len(kb.comments) == 0 {
		return ""
	}
	return commentString(kb.comments, prefix)
}

func (kb Keybinding) KeyString() string {
	return kb.KeybindingEntry.Key
}

func (kb Keybinding) ConflictsWith(other Keybinding) bool {
	return len(kb.comments) > 0 && len(other.comments) > 0
}

// WithComment returns a copy of the keybinding with the given comment added.
func (kb Keybinding) WithComment(comment string) Keybinding {
	kb.comments = []string{comment}
	return kb
}

func (kb Keybinding) String() string {
	data, err := marshalKeybinding(kb, "", "   ")
	if err != nil {
		slog.Error("failed to marshal keybinding", "error", err, "entry", kb.KeybindingEntry)
		panic(err)
	}
	return kb.CommentString("") + string(data)
}
