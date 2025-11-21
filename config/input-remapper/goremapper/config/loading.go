package config

import (
	"encoding/json"
	"os"
)

func LoadConfig(filePath string) (Config, error) {
	contents, err := os.ReadFile(filePath)
	if err != nil {
		return Config{}, err
	}
	config := Config{
		Autoload: make(map[Device]string),
	}
	err = json.Unmarshal(contents, &config)
	return config, err
}

func SaveConfig(filePath string, config Config) error {
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filePath, data, 0644)
}
