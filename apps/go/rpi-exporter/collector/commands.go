package collector

import (
	"fmt"
	"log/slog"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
)

// systemLock prevents command overload.
// Only one command should be called at time to high load on the system.
var systemLock = &sync.Mutex{}
var isRpi = atomic.Bool{}
var once = sync.Once{}

// best-effort check if we use a pi or not
func IsRpi() bool {
	once.Do(func() {
		// quick check
		cmd := exec.Command("which", "raspi-config")
		_, err := cmd.CombinedOutput()
		status := err == nil
		if status {
			slog.Info("raspi-config not found, storing raspi status", "is_rpi", status)
		} else {
			slog.Warn("raspi-config not found, storing raspi status", "is_rpi", status, "error", err)
		}
		isRpi.Store(status)
	})
	return isRpi.Load()
}

// GetVoltage runs vcgencmd measure_volts for a given port and returns the voltage.
func GetVoltage(port string) (float64, error) {
	systemLock.Lock()
	defer systemLock.Unlock()

	if !IsRpi() {
		// return a dummy to allow testing on non-Pis
		return 1.2, nil
	}

	cmd := exec.Command("vcgencmd", "measure_volts", port)
	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("failed to run vcgencmd measure_volts %s: %w", port, err)
	}

	// Example output: volt=1.2000V
	re := regexp.MustCompile(`volt=(\d+\.?\d*)V`)
	matches := re.FindStringSubmatch(string(output))
	if len(matches) < 2 {
		return 0, fmt.Errorf("could not parse voltage from output: %s", string(output))
	}

	voltageStr := matches[1]
	voltage, err := strconv.ParseFloat(voltageStr, 64)
	if err != nil {
		return 0, fmt.Errorf("could not parse float from voltage string '%s': %w", voltageStr, err)
	}

	return voltage, nil
}

// GetThrottledStatus runs vcgencmd get_throttled and returns the status as a float64.
func GetThrottledStatus() (float64, error) {
	systemLock.Lock()
	defer systemLock.Unlock()

	if !IsRpi() {
		// return a dummy to allow testing on non-Pis
		return 0.0, nil
	}

	cmd := exec.Command("vcgencmd", "get_throttled")
	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("failed to run vcgencmd get_throttled: %w", err)
	}

	// Example output: throttled=0x0
	re := regexp.MustCompile(`throttled=(0x[0-9a-fA-F]+)`)
	matches := re.FindStringSubmatch(strings.TrimSpace(string(output)))
	if len(matches) < 2 {
		return 0, fmt.Errorf("could not parse throttled status from output: %s", string(output))
	}

	statusHex := matches[1]
	// Parse hex string to integer, then convert to float64 for the gauge
	statusInt, err := strconv.ParseInt(statusHex, 0, 64) // 0 infers base from prefix (0x)
	if err != nil {
		return 0, fmt.Errorf("could not parse int from throttled status hex '%s': %w", statusHex, err)
	}

	return float64(statusInt), nil
}
