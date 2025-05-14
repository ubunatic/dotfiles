package collector

import (
	"log/slog"

	"github.com/prometheus/client_golang/prometheus"
)

const (
	VoltagePortCore   = "core"
	VoltagePortSDRamC = "sdram_c"
	VoltagePortSDRamP = "sdram_p"
	VoltagePortSDRamI = "sdram_i"

	ClockIDARM  = "arm"
	ClockIDCore = "core"

	MemIDARM = "arm"
	MemIDGPU = "gpu"
)

func VoltagePorts() []string {
	return []string{VoltagePortCore, VoltagePortSDRamC, VoltagePortSDRamP, VoltagePortSDRamI}
}

func ClockIDs() []string { return []string{ClockIDARM, ClockIDCore} }
func MemIDs() []string   { return []string{MemIDARM, MemIDGPU} }

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
	temperatureGauge = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "rpi_temperature_celsius",
			Help: "Temperature of the Raspberry Pi SoC in Celsius.",
		},
	)
	clockGauge = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Name: "rpi_clock_frequency_hertz",
			Help: "Clock frequency of various Raspberry Pi components in Hertz.",
		},
		[]string{"id"},
	)
	memoryGauge = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Name: "rpi_memory_bytes",
			Help: "Memory allocated to various Raspberry Pi components in Bytes.",
		},
		[]string{"id"},
	)
)

type RPiCollector struct{}

func NewRPiCollector() *RPiCollector { return &RPiCollector{} }

// Describe implements the prometheus.Collector interface.
func (c *RPiCollector) Describe(ch chan<- *prometheus.Desc) {
	voltageGauge.Describe(ch)
	throttledGauge.Describe(ch)
	temperatureGauge.Describe(ch)
	clockGauge.Describe(ch)
	memoryGauge.Describe(ch)
}

// Collect implements the prometheus.Collector interface.
func (c *RPiCollector) Collect(ch chan<- prometheus.Metric) {
	// Collect voltage metrics
	for _, port := range VoltagePorts() {
		voltage, err := GetVoltage(port)
		if err != nil {
			slog.Error("Error collecting voltage", "port", port, "error", err)
			continue
		}
		voltageGauge.WithLabelValues(port).Set(voltage)
	}

	// Collect throttled status (GetThrottledStatus is concurrency-safe)
	throttled, err := GetThrottledStatus()
	if err != nil {
		slog.Error("Error collecting throttled status", "error", err)
	} else {
		throttledGauge.Set(throttled)
	}

	// Collect temperature
	temp, err := GetTemperature()
	if err != nil {
		slog.Error("Error collecting temperature", "error", err)
	} else {
		temperatureGauge.Set(temp)
	}

	// Collect clock frequencies
	for _, id := range ClockIDs() {
		freq, err := GetClock(id)
		if err != nil {
			slog.Error("Error collecting clock frequency", "id", id, "error", err)
			continue
		}
		clockGauge.WithLabelValues(id).Set(freq)
	}

	// Collect memory allocation
	for _, id := range MemIDs() {
		mem, err := GetMemory(id)
		if err != nil {
			slog.Error("Error collecting memory", "id", id, "error", err)
			continue
		}
		memoryGauge.WithLabelValues(id).Set(mem)
	}

	// Send metrics to the channel
	voltageGauge.Collect(ch)
	throttledGauge.Collect(ch)
	temperatureGauge.Collect(ch)
	clockGauge.Collect(ch)
	memoryGauge.Collect(ch)
}
