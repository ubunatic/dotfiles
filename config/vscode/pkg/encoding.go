package vscode

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"os"
	"strings"
)

// BindingFileDecoder parse the JSON with comments from a Keybindings files as:
//
//	// File-level comment
//	[ <-- must be on its own line
//	  // comment line 1
//	  // comment line 2
//	  { single or multi-line JSON binding }, <-- may be followed by a comma
//	  // ...
//	] <-- must be on its own line
type BindingFileDecoder struct {
	reader io.Reader
}

func (d *BindingFileDecoder) Decode(b *BindingFile) error {
	// parse strategy:
	// 1. read line by line (header first as then then bindings trimmed)
	// 2. trim whitespace
	// 3. if line starts with //, treat as comment
	// 4. if line is empty, continue
	// 5. if line is a JSON object, unmarshal into Keybinding

	scanner := bufio.NewScanner(d.reader)

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

	return io.EOF
}

func ReadKeybindings(file string) (*BindingFile, error) {
	f, err := os.Open(file)
	if err != nil {
		return nil, fmt.Errorf("failed to open keybindings file %s: %w", file, err)
	}
	defer f.Close()

	decoder := BindingFileDecoder{reader: f}
	b := &BindingFile{
		file:        f,
		Comments:    []string{},
		KeyBindings: []Keybinding{},
	}

	for {
		if err := decoder.Decode(b); err != nil {
			if err == io.EOF {
				break
			}
			return nil, fmt.Errorf("failed to decode keybinding from %s: %w", file, err)
		}
	}
	return b, nil
}
