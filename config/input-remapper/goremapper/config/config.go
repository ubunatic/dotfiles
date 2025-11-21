package config

import (
	"bytes"
	"encoding/json"
	"fmt"
	"slices"
)

type Device struct {
	name string
	pos  int
}

func (k Device) MarshalText() ([]byte, error) {
	return []byte(k.Name()), nil
}

func (k Device) String() string { return fmt.Sprintf("Device{name: %s, pos: %d}", k.name, k.pos) }
func (k Device) Name() string   { return k.name }
func (k Device) Pos() int       { return k.pos }

type Config struct {
	Autoload map[Device]string `json:"autoload"`
}

func (c *Config) DeviceByPos(i int) string {
	for device := range c.Autoload {
		if i == device.Pos() {
			return device.Name()
		}
	}
	return ""
}

func (c *Config) DeviceByName(name string) string {
	for device := range c.Autoload {
		if device.Name() == name {
			return device.Name()
		}
	}
	return ""
}

func (c *Config) Preset(device string) string {
	for dev, preset := range c.Autoload {
		if dev.Name() == device {
			return preset
		}
	}
	return ""
}

func (c *Config) SetPreset(device string, preset string) {
	for dev := range c.Autoload {
		if dev.Name() == device {
			c.Autoload[dev] = preset
			return
		}
	}
	c.Autoload[Device{name: device, pos: len(c.Autoload)}] = preset
}

func (c *Config) UnmarshalJSON(data []byte) error {
	// unmarshal into a temporary map to extract autoload section
	m := map[string]any{}
	err := json.Unmarshal(data, &m)
	if err != nil {
		return err
	}
	autoload := m["autoload"].(map[string]any)

	// find positions of device names in the original JSON data
	// they should be unique and in the order defined by the system
	indexes := []int{}
	tmp := &Config{
		Autoload: make(map[Device]string),
	}
	for k, v := range autoload {
		idx := bytes.Index(data, []byte(k))
		if idx == -1 {
			return fmt.Errorf("failed to find device name in JSON data")
		}
		indexes = append(indexes, idx)
		// temporarily store with position as index
		tmp.Autoload[Device{name: k, pos: idx}] = v.(string)
	}

	// sort devices by their positions in the JSON data
	slices.Sort(indexes)

	for i, idx := range indexes {
		name := tmp.DeviceByPos(idx)
		preset := tmp.Preset(name)
		if name == "" {
			return fmt.Errorf("failed to find device for index %d", idx)
		}
		c.Autoload[Device{name: name, pos: i}] = preset
	}

	return nil
}
