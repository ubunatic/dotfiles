package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"strings"

	"codeberg.org/ubunatic/goremapper/binding"
	"codeberg.org/ubunatic/goremapper/config"
)

func main() {
	// flags
	var configFile = flag.String("config", "~/.config/input-remapper-2/config.json", "Path to the JSON config file")
	var deviceName = flag.String("device", "", "Device name to set as autoload")

	// read actions
	var getDevice = flag.Int("get-device", -1, "Show autoload device name by position from config file")
	var getPreset = flag.String("get-preset", "", "Show current autoload preset")
	var getConfig = flag.Bool("get-config", false, "Show loaded config and exit")

	// write actions
	var setPreset = flag.String("set-preset", "", "Set autoload device name in config file")

	flag.Parse()

	*configFile = strings.Replace(*configFile, "~", os.Getenv("HOME"), 1)
	cfg, err := config.LoadConfig(*configFile)
	exitOnError(err)
	slog.Info("Loaded config", "config", cfg)

	if *getConfig {
		fmt.Println(cfg)
		return
	}

	if *getPreset != "" {
		dev := getIputDevice(deviceName, cfg)
		preset := cfg.Preset(dev)
		slog.Info("Current autoload preset", "device", dev, "preset", preset)
		printBindings(*getPreset)
		return
	}

	switch {
	case *getDevice >= 0:
		fmt.Println(cfg.DeviceByPos(*getDevice))
	case *setPreset != "":
		dev := getIputDevice(deviceName, cfg)
		cfg.SetPreset(dev, *setPreset)
		err = config.SaveConfig(*configFile, cfg)
		exitOnError(err)
		slog.Info("Updated config", "config", cfg)
	default:
		slog.Info("No valid actions provided, use either -get-device or -set-preset")
		usage()
		os.Exit(1)
	}
}

func usage() { flag.Usage() }

func exitOnError(err error) {
	if err == nil {
		return
	}
	slog.Error("Error", "error", err)
	os.Exit(1)
}

func getIputDevice(deviceName *string, cfg config.Config) string {
	dev := *deviceName
	if dev == "" {
		slog.Info("Device name not provided, using existing autoload device if available")
		dev = cfg.DeviceByName(dev)
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

func loadPresetBindings(preset string) ([]binding.Entry, error) {
	filePath := fmt.Sprintf("%s.json", preset)
	contents, err := os.ReadFile(filePath)
	if err != nil {
		return nil, err
	}
	var bindings []binding.Entry
	err = json.Unmarshal(contents, &bindings)
	return bindings, err
}
