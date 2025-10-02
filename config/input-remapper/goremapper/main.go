package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"strings"
)

type AutoloadConfig struct {
	Autoload map[string]string `json:"autoload"`
}

func (c *AutoloadConfig) GetDevice() string {
	for key := range c.Autoload {
		return key
	}
	return ""
}

func loadConfig(filePath string) (AutoloadConfig, error) {
	contents, err := os.ReadFile(filePath)
	if err != nil {
		return AutoloadConfig{
			Autoload: make(map[string]string),
		}, err
	}
	var config AutoloadConfig
	err = json.Unmarshal(contents, &config)
	return config, err
}

func saveConfig(filePath string, config AutoloadConfig) error {
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filePath, data, 0644)
}

func usage() { flag.Usage() }
func exitOnError(err error) {
	if err == nil {
		return
	}
	slog.Error("Error", "error", err)
	os.Exit(1)
}

func main() {
	var configFile = flag.String("config", "~/.config/input-remapper-2/config.json", "Path to the JSON config file")
	var getDevice = flag.Bool("get-device", false, "Get autoload device name from config file")
	var setPreset = flag.String("set-preset", "", "Set autoload device name in config file")
	var showPreset = flag.String("show-preset", "", "Show current autoload preset")
	var deviceName = flag.String("device", "", "Device name to set as autoload")
	flag.Parse()

	*configFile = strings.Replace(*configFile, "~", os.Getenv("HOME"), 1)
	cfg, err := loadConfig(*configFile)
	exitOnError(err)
	slog.Info("Loaded config", "config", cfg)

	if *showPreset != "" {
		dev := getIputDevice(deviceName, cfg)
		preset, _ := cfg.Autoload[dev]
		slog.Info("Current autoload preset", "device", dev, "preset", preset)
		printBindings(*showPreset)
		return
	}

	switch {
	case *getDevice:
		fmt.Println(cfg.GetDevice())
	case *setPreset != "":
		dev := getIputDevice(deviceName, cfg)
		cfg.Autoload[dev] = *setPreset
		err = saveConfig(*configFile, cfg)
		exitOnError(err)
		slog.Info("Updated config", "config", cfg)
	default:
		slog.Info("No valid actions provided, use either -get-device or -set-preset")
		usage()
		os.Exit(1)
	}
}

func getIputDevice(deviceName *string, cfg AutoloadConfig) string {
	dev := *deviceName
	if dev == "" {
		slog.Info("Device name not provided, using existing autoload device if available")
		dev = cfg.GetDevice()
	}
	if dev == "" {
		exitOnError(fmt.Errorf("no device found in config"))
	}
	return dev
}

func printBindings(preset string) {
	bindings, err := loadPresetBindings(preset)
	exitOnError(err)
	for _, b := range bindings {
		fmt.Println(b.String())
	}
}

func loadPresetBindings(preset string) ([]BindingEntry, error) {
	filePath := fmt.Sprintf("%s.json", preset)
	contents, err := os.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	var bindings []BindingEntry
	err = json.Unmarshal(contents, &bindings)
	return bindings, err
}

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

type BindingEntry struct {
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

func (b BindingEntry) String() string {
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
