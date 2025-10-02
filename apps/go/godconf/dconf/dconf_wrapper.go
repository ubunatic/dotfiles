package dconf

import (
	"fmt"
	"log/slog"
	"os/exec"
	"regexp"
	"slices"
	"strings"
)

func Exec(args ...string) (string, error) {
	cmdInfo := strings.Join(append([]string{"dconf"}, args...), " ")
	slog.Debug("Executing dconf command", "cmd", cmdInfo)

	out, err := exec.Command("dconf", args...).Output()
	if err != nil {
		slog.Error("dconf command failed", "args", args, "error", err, "output", string(out))
		return "", fmt.Errorf("dconf %s: %w", strings.Join(args, " "), err)
	}
	return strings.TrimSpace(string(out)), nil
}

func ParseArray(v string) ([]string, error) {
	v = strings.TrimSpace(v)
	if v == "" || v == "[]" {
		return nil, nil
	}
	if !strings.HasPrefix(v, "[") || !strings.HasSuffix(v, "]") {
		// Not an array, return single item or empty
		return nil, fmt.Errorf("not an array: %q", v)
	}
	v = strings.TrimPrefix(v, "[")
	v = strings.TrimSuffix(v, "]")
	v = strings.TrimSpace(v)

	// Regex explanation:
	//   '([^']*)'            matches single-quoted strings, capturing everything except single quotes
	//   "((?:\\.|[^"\\])*)"  matches double-quoted strings, where the content is one of:
	//                        - any escaped character (e.g. \", \\), which handles all backslash cases
	// 					      - any character except double quotes or backslashes, with the backslashes being excluded to
	//                          prevent them from ending the string, which would be a syntax error next to the closing quote
	re := regexp.MustCompile(`'([^']*)'|"((?:\\.|[^"\\])*)"`)
	matches := re.FindAllStringSubmatch(strings.TrimSpace(v), -1)
	var items []string
	for _, m := range matches {
		if m[1] != "" {
			// single-quoted
			items = append(items, m[1])
		} else {
			// double-quoted, unescape
			s := m[2]
			s = strings.ReplaceAll(s, `\"`, `"`)
			items = append(items, s)
		}
	}
	return items, nil
}

// ReadArray reads a dconf array value and parses it into a slice of strings.
func ReadArray(path string) ([]string, error) {
	raw, err := Exec("read", path)
	if err != nil {
		return nil, err
	}
	return ParseArray(raw)
}

func WriteArray(path string, items []string, dryRun bool) error {
	quoted := make([]string, len(items))
	for i, item := range items {
		quoted[i] = fmt.Sprintf("'%s'", item)
	}
	v := fmt.Sprintf("[%s]", strings.Join(quoted, ", "))
	ShowEntries("Writing dconf array:", items)
	if dryRun {
		fmt.Println("DRY RUN: dconf write", path, v)
		return nil
	}
	_, err := Exec("write", path, v)
	return err
}

// ReadList lists the entries under the given dconf path.
// Example: dconf list /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ <-- the slash at the end is important!
func ReadList(path string, key string) ([]string, error) {
	raw, err := Exec("list", path)
	if err != nil {
		return nil, err
	}
	lines := strings.Split(strings.TrimSpace(raw), "\n")
	for i, line := range lines {
		if strings.HasSuffix(line, "/") && key != "" {
			line, err = Exec("read", path+line+key)
			if err != nil {
				slog.Error("Failed to read key from dconf path", "path", path+line, "key", key, "error", err)
				continue
			}
			lines[i] = line
		}
	}
	return lines, nil
}

func ShowEntries(header string, entries []string) {
	fmt.Println(header)
	for _, entry := range entries {
		fmt.Printf("  - %s\n", entry)
	}
}

func Unique(items ...[]string) []string {
	combined := slices.Concat(items...)
	slices.Sort(combined)
	return slices.Compact(combined)
}

const KeyCustomKeybindings = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
const KeyCustomKeybindingsList = KeyCustomKeybindings + "/"

var KeyCustomRe = regexp.MustCompile(`^` + regexp.QuoteMeta(KeyCustomKeybindingsList) + `custom[0-9]+/$`)
