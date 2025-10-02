package main

// AI Instructions:
// See ./hiccup entrypoint script for more details.
// Implement a Go program that monitors system hiccups and logs them.

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"ubunatic.com/dotapps/go/gohiccup/hiccupwatch"
)

func setupContext() context.Context {
	// capture interrupt SIGINT and SIGTERM signals to allow graceful shutdown
	// and cancel the context
	ctx, _ := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	return ctx
}

func main() {
	slog.Info("Starting hiccup monitoring")

	// Start monitoring hiccups
	// This is a placeholder for the actual hiccup monitoring logic
	// In a real implementation, you would replace this with code that
	// monitors system hiccups and logs them accordingly.

	ctx := setupContext()
	go hiccupwatch.WatchHiccups(ctx, hiccupwatch.HiccupCallbackLogCounter)
	<-ctx.Done()

	slog.Info("Exiting hiccup monitoring")
}
