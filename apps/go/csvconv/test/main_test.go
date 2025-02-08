package csvconv_test

import (
	"log/slog"
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	"ubunatic.com/dotapps/go/csvconv"
)

func TestCli(t *testing.T) {
	f1 := os.TempDir() + "/csvconv_test_data.csv"
	f2 := os.TempDir() + "/csvconv_test_data2.csv"
	defer os.Remove(f1)
	defer os.Remove(f2)

	err := os.WriteFile(f1, []byte(strings.Join([]string{
		"a,b,c", "1,2", "4,5,6,7",
	}, "\n")), 0o644)

	app := csvconv.App()
	args := []string{"csvconv", "-v", "-d", ",", "-D", ";", "-H", "1", "convert", f1, f2}
	err = app.Run(args)
	slog.Debug("Error", "error", err)
	require.NoError(t, err)

	data, err := os.ReadFile(f2)
	require.NoError(t, err)
	require.Equal(t, strings.Join([]string{
		"1;2", "4;5;6;7\n",
	}, "\n"), string(data))
}
