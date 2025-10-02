package hiccupwatch

// AI Instructions:
// See ./hiccup entrypoint script for more details.
// Implement a Go program that monitors system hiccups and logs them.

import (
	"context"
	"fmt"
	"log/slog"
	"sync/atomic"
	"time"
)

var numLogs atomic.Int64

type HiccupState string

const (
	HiccupStart   HiccupState = "start"
	HiccupOngoing HiccupState = "ongoing"
	HiccupEnd     HiccupState = "end"
)

type HiccupLog struct {
	Timestamp time.Time
	Record    slog.Record
	State     HiccupState
}

func HiccupCallbackLogCounter(logLines []HiccupLog) {
	numLogs.Add(int64(len(logLines)))
	fmt.Printf("\r Logs collected %d", numLogs.Load())
}

func WatchHiccups(ctx context.Context, showCounter func([]HiccupLog)) {
	// Placeholder for hiccup monitoring logic
	// In a real implementation, this function would monitor system hiccups
	// and log them accordingly.
	for {
		select {
		case <-ctx.Done():
			slog.Info("Stopping hiccup monitoring")
			return
		case <-time.After(1 * time.Second):
			// Simulate periodic check
			numLogs.Add(1)
			HiccupCallbackLogCounter([]HiccupLog{{
				Timestamp: time.Now(),
				Record:    slog.Record{Time: time.Now(), Level: slog.LevelInfo, Message: "Hiccup detected"},
				State:     HiccupOngoing,
			}})
		}
	}
}
