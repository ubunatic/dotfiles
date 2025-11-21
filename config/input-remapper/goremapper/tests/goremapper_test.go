package tests

import (
	"fmt"
	"testing"

	"codeberg.org/ubunatic/goremapper/config"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var tmpDir string

func TestGoremapper(t *testing.T) {
	RegisterFailHandler(Fail)
	tmpDir = t.TempDir()
	RunSpecs(t, "Goremapper Suite")
}

var _ = Describe("Goremapper", func() {
	It("should load config without error", func() {
		filePath := "../../config.json"
		cfg, err := config.LoadConfig(filePath)
		Expect(err).ToNot(HaveOccurred())
		Expect(cfg).ToNot(BeNil())
		Expect(cfg.Autoload).ToNot(BeNil())
		Expect(len(cfg.Autoload)).To(BeNumerically(">", 1))
		d1 := cfg.DeviceByPos(0)
		d2 := cfg.DeviceByPos(1)
		fmt.Println("Device at pos 0:", d1)
		fmt.Println("Device at pos 1:", d2)
		Expect(d1).ToNot(BeEmpty())
		Expect(d2).ToNot(BeEmpty())
		preset1 := cfg.Preset(d1)
		preset2 := cfg.Preset(d2)
		fmt.Println("Preset for device", d1, ":", preset1)
		fmt.Println("Preset for device", d2, ":", preset2)
		Expect(preset1).ToNot(BeEmpty())
		Expect(preset2).ToNot(BeEmpty())
	})
})

var _ = Describe("Goremapper", func() {
	It("should marshal and unmarshal config without error", func() {
		filePath := "../../config.json"
		cfg, err := config.LoadConfig(filePath)
		Expect(err).ToNot(HaveOccurred())
		Expect(cfg).ToNot(BeNil())

		filePath2 := tmpDir + "/config_copy.json"
		err = config.SaveConfig(filePath2, cfg)
		Expect(err).ToNot(HaveOccurred())

		cfg2, err := config.LoadConfig(filePath2)
		Expect(err).ToNot(HaveOccurred())
		Expect(cfg2).ToNot(BeNil())
		Expect(cfg2.Autoload).ToNot(BeNil())
		Expect(len(cfg2.Autoload)).To(Equal(len(cfg.Autoload)))

		for dev, preset := range cfg.Autoload {
			preset2 := cfg2.Preset(dev.Name())
			Expect(preset2).To(Equal(preset))
		}
	})
})
