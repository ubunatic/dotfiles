package vscode

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log/slog"
	"os"
	"strings"
)

func ReadKeybindings(file string) (*BindingFile, error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, fmt.Errorf("failed to open keybindings file %s: %w", file, err)
	}
	defer f.Close()

	b, err := unmarshalKeybindings(f)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal keybindings from %s: %w", file, err)
	}
	return b, nil
}

// unmarshalKeybindings parses input data as JSON with comments
// from a keybindings.json files as follows.
//
//	// File-level comment
//	[ <-- must be on its own line
//	  // comment line 1
//	  // comment line 2
//	  { single or multi-line JSON binding }, <-- may be followed by a comma
//	  // ...
//	] <-- must be on its own line
func unmarshalKeybindings(f *os.File) (*BindingFile, error) {
	// parse strategy:
	// 1. read line by line (header first as then then bindings trimmed)
	// 2. trim whitespace
	// 3. if line starts with //, treat as comment
	// 4. if line is empty, continue
	// 5. if line is a JSON object, unmarshal into Keybinding

	b := &BindingFile{
		file:        f,
		Comments:    []string{},
		KeyBindings: []Keybinding{},
	}
	scanner := bufio.NewScanner(f)

	// scan header until "["
	for scanner.Scan() {
		line := scanner.Text()
		if line == "[" {
			// end header processing
			break
		}
		b.Comments = append(b.Comments, line)
	}

	var commentLines []string // comment lines before a keybinding
	var pendingLines []string // lines for a multi-line keybinding

	// scan bindings until "]"
	for scanner.Scan() {
		line := scanner.Text()
		if line == "]" {
			// untrimmed "]" must be the root-level end of the bindings
			break
		}
		line = strings.TrimSpace(line)

		switch {
		case line == "":
			continue
		case strings.HasPrefix(line, "//"):
			// add lines as is with "//"
			commentLines = append(commentLines, line)
			continue
		default:
			pendingLines = append(pendingLines, line)
		}

		// try to parse pending lines
		joined := strings.Join(pendingLines, "\n")
		joined = strings.TrimSuffix(joined, ",") // remove trailing comma if any
		// best effort, since internal trailing commas are not supported

		var entry KeybindingEntry
		if err := json.Unmarshal([]byte(joined), &entry); err != nil {
			// not ready yet, keep going
			// lines are preserved in pendingLines
			continue
		}
		b.KeyBindings = append(b.KeyBindings, Keybinding{
			comments:        commentLines,
			KeybindingEntry: entry,
		})

		slog.Info("decoded keybinding",
			"entry", entry,
			"comments", commentLines,
			"file", b.file.Name(),
		)

		pendingLines = nil
		commentLines = nil
	}

	// scan the rest and log it
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line != "" {
			pendingLines = append(pendingLines, line)
		}
	}

	if len(pendingLines) > 0 {
		slog.Warn("leftover lines after parsing keybindings",
			"lines", pendingLines,
		)
	}

	return b, nil
}

func marshalKeybinding(kb Keybinding, prefix, indent string) ([]byte, error) {
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
	res := strings.TrimRight(w.String(), "\n")

	// remove without trailing newline to allow for `},` closing in lists
	return []byte(res), nil
}

func marshalKeybindings(kbs KeyBindings, prefix, indent string) ([]byte, error) {
	var result []byte
	for i, binding := range kbs {
		data, err := marshalKeybinding(binding, prefix+indent, indent)
		if err != nil {
			return nil, err
		}
		if len(binding.comments) > 0 {
			result = append(result, []byte("\n")...) // separate commented keybindings visually
		}
		result = append(result, data...)
		if i < len(kbs)-1 {
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

func commentString(comments []string, indent string) string {
	var sb strings.Builder
	for _, comment := range comments {
		sb.WriteString(indent)
		sb.WriteString(comment)
		sb.WriteString("\n")
	}
	return sb.String()
}
