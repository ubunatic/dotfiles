package vscode

import (
	"encoding/json"
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
	data, err := kb.MarshalJSONCIndent("", "   ")
	if err != nil {
		slog.Error("failed to marshal keybinding", "error", err, "entry", kb.KeybindingEntry)
		panic(err)
	}
	return kb.CommentString("") + string(data)
}

func (kb Keybinding) MarshalJSONCIndent(prefix, indent string) ([]byte, error) {
	w := &strings.Builder{}

	// start with comments
	w.Write([]byte(kb.CommentString(prefix)))

	// then add JSON without HTML escaping
	w.Write([]byte(prefix))
	enc := json.NewEncoder(w)
	enc.SetEscapeHTML(false)
	enc.SetIndent(prefix, indent)
	if err := enc.Encode(kb.KeybindingEntry); err != nil {
		return nil, err
	}

	// remove without trailing newline to allow for `},` closing in lists
	return []byte(strings.TrimRight(w.String(), "\n")), nil
}

func commentString(comments []string, indent string) string {
	var sb strings.Builder
	for _, comment := range comments {
		sb.WriteString(indent)
		sb.WriteString(comment)
		sb.WriteString("\n")
	}
	return sb.String()
}

func normalizeKey(key string) string {
	return strings.ToLower(strings.TrimSpace(key))
}
