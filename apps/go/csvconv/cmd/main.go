package main

import (
	"log/slog"
	"os"

	"ubunatic.com/dotapps/go/csvconv"
)

func main() {
	err := csvconv.App().Run(os.Args)
	if err != nil {
		slog.Error("Error", "error", err)
		os.Exit(1)
	}
}
