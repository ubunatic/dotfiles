package main

import (
	"log/slog"

	"ubunatic.com/dotapps/go/gololog"
)

func main() {
	gololog.SetupColoredSlogLogging()
	slog.Info("Starting gololog demo")
	slog.Debug("This is a debug message", slog.String("key1", "value1"))
	slog.Info("This is an info message", slog.Int("key2", 42))
	slog.Warn("This is a warning message", slog.Float64("key3", 3.14))
	slog.Error("This is an error message", slog.String("key4", "error details"))
}
