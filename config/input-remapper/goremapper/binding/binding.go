package binding

import (
	"fmt"
	"strings"
)

// Example binding entry:
// {
//     "input_combination": [
//         {"type": 1, "code": 125, "origin_hash": "f41857944f231401fd2a41d9b959607a"},
//         {"type": 1, "code": 105, "origin_hash": "f41857944f231401fd2a41d9b959607a"}
//     ],
//     "target_uinput": "keyboard",
//     "output_symbol": "KEY_LEFTCTRL + Left",
//     "name": "text-nav: Super+\u27a1\ufe0f >> Ctrl+\u27a1\ufe0f  (\ud83c\udf4f Opt+\u27a1\ufe0f)",
//     "mapping_type": "key_macro"
// }

type Entry struct {
	InputCombination []InputEvent `json:"input_combination"`
	TargetUinput     string       `json:"target_uinput"`
	OutputSymbol     string       `json:"output_symbol"`
	Name             string       `json:"name"`
	MappingType      string       `json:"mapping_type"`
}

type InputEvent struct {
	Type       int    `json:"type"`
	Code       int    `json:"code"`
	OriginHash string `json:"origin_hash"`
}

func (b Entry) String() string {
	codes := make([]string, len(b.InputCombination))
	for i, ev := range b.InputCombination {
		codes[i] = keyNameForCode(ev.Code, ev.Type)
	}
	return fmt.Sprintf("%s: %s: %s", strings.Join(codes, "+"), b.OutputSymbol, b.Name)
}

func keyNameForCode(code int, _ int) string {
	switch code {
	case 125:
		return "Super"
	case 126:
		return "Super"
	case 29:
		return "Ctrl"
	case 42:
		return "Shift"
	case 16:
		return "Meta"
	case 56:
		return "Alt"
	case 27:
		return "Left"
	case 106:
		return "Right"
	case 86:
		return "Backquote/Less"
	case 39:
		return "Semicolon/Ö"
	case 40:
		return "Apostrophe/Ä"
	case 8:
		return "Key_7"
	case 9:
		return "Key_8"
	case 10:
		return "Key_9"
	case 11:
		return "Key_0"
	case 57:
		return "Space"
	default:
		return fmt.Sprintf("Code_%d", code)
	}
}
