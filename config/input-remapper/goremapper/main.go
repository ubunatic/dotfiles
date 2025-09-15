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
	var deviceName = flag.String("device", "", "Device name to set as autoload")
	flag.Parse()

	*configFile = strings.Replace(*configFile, "~", os.Getenv("HOME"), 1)
	cfg, err := loadConfig(*configFile)
	exitOnError(err)
	slog.Info("Loaded config", "config", cfg)

	switch {
	case *getDevice:
		fmt.Println(cfg.GetDevice())
	case *setPreset != "":
		dev := *deviceName
		if dev == "" {
			slog.Info("Device name not provided, using existing autoload device if available")
			dev = cfg.GetDevice()
		}
		if dev == "" {
			exitOnError(fmt.Errorf("no device found in config"))
		}

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
