package collector_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	"ubunatic.com/dotapps/go/rpi-exporter/collector"
)

func TestCommands(t *testing.T) {
	v, err := collector.GetThrottledStatus()
	require.NoError(t, err)
	require.GreaterOrEqual(t, v, 0.0)

	for _, port := range collector.VoltagePorts() {
		t.Run(port, func(t *testing.T) {
			v, err = collector.GetVoltage(port)
			require.NoError(t, err)
			require.GreaterOrEqual(t, v, 0.0)
		})
	}
}

func TestIsRpi(t *testing.T) {
	v := collector.IsRpi()
	t.Log("IsRpi:", v)
}
