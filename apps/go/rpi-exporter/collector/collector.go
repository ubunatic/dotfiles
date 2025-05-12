package collector

import (
	"log"

	"github.com/prometheus/client_golang/prometheus"
)

const (
	VoltagePortCore   = "core"
	VoltagePortSDRamC = "sdram_c"
	VoltagePortSDRamP = "sdram_p"
	VoltagePortSDRamI = "sdram_i"
)

func VoltagePorts() []string {
	return []string{VoltagePortCore, VoltagePortSDRamC, VoltagePortSDRamP, VoltagePortSDRamI}
}

var (
	voltageGauge = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Name: "rpi_voltage_volts",
			Help: "Voltage of various Raspberry Pi components in Volts.",
		},
		[]string{"port"},
	)
	throttledGauge = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "rpi_throttled_status",
			Help: "Raspberry Pi throttled status (bitmask). See vcgencmd get_throttled output.",
		},
	)
)

type RPiCollector struct{}

func NewRPiCollector() *RPiCollector { return &RPiCollector{} }

// Describe implements the prometheus.Collector interface.
func (c *RPiCollector) Describe(ch chan<- *prometheus.Desc) {
	voltageGauge.Describe(ch)
	throttledGauge.Describe(ch)
}

// Collect implements the prometheus.Collector interface.
func (c *RPiCollector) Collect(ch chan<- prometheus.Metric) {
	// Collect voltage metrics
	for _, port := range VoltagePorts() {
		voltage, err := GetVoltage(port)
		if err != nil {
			log.Printf("Error collecting voltage for %s: %v", port, err)
			continue
		}
		voltageGauge.WithLabelValues(port).Set(voltage)
	}

	// Collect throttled status (GetThrottledStatus is concurrency-safe)
	throttled, err := GetThrottledStatus()
	if err != nil {
		log.Printf("Error collecting throttled status: %v", err)
	} else {
		throttledGauge.Set(throttled)
	}

	// Send metrics to the channel
	voltageGauge.Collect(ch)
	throttledGauge.Collect(ch)
}
