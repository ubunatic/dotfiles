package main_test

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
		`a,b,c`,
		`1.1,2.123`,
		`"1,454,345.12",5,6,7,0,-1.0,"-19,123,345.00"`,
		"", // nl
	}, "\n")), 0o644)

	app := csvconv.App()
	args := []string{"csvconv", "-v", "-d", ",;", "-f", f1, "-o", f2, "select a,b,c,4,5,6,7 | numbers dot:comma"}
	err = app.Run(args)
	slog.Debug("Error", "error", err)
	require.NoError(t, err)

	data, err := os.ReadFile(f2)
	require.NoError(t, err)
	require.Equal(t, strings.Join([]string{
		"a;b;c;;;;",
		"1,1;2,123;;;;;",
		"1.454.345,12;5;6;7;0;-1,0;-19.123.345,00",
		"", // nl
	}, "\n"), string(data))
}

func TestHelp(t *testing.T) {
	app := csvconv.App()
	args := []string{"csvconv", "--help"}
	err := app.Run(args)
	require.NoError(t, err)
}
