package gololog

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"runtime"
	"strings"
)

// Color codes for terminal output
const (
	ColorReset  = "\033[0m"
	ColorRed    = "\033[31m"
	ColorGreen  = "\033[32m"
	ColorYellow = "\033[33m"
	ColorBlue   = "\033[34m"
	ColorPurple = "\033[35m"
	ColorCyan   = "\033[36m"
	ColorDimmed = "\033[2m" // Dim or faint

	ColorBold      = "\033[1m"
	ColorUnderline = "\033[4m"
)

// Emojis for log levels and source
const (
	SourceEmoji = "📍"   // Emoji to indicate source file and line number
	AttrEmoji   = ""    // Emoji to indicate key-value attributes (no good one found so far)
	DebugEmoji  = "🪲"   // Emoji for debug leve
	InfoEmoji   = "ℹ️ " // Emoji for info level
	WarnEmoji   = "⚠️ " // Emoji for warning level
	ErrorEmoji  = "❌"   // Emoji for error level
)

const (
	TimeFormat = "2006-01-02 15:04:05.000" // with milliseconds

	MinMessageWidth = 40
)

func b(s string) string   { return ColorBold + s + ColorReset }
func ul(s string) string  { return ColorUnderline + s + ColorReset }
func dim(s string) string { return ColorDimmed + s + ColorReset }
func grn(s string) string { return ColorGreen + s + ColorReset }
func blu(s string) string { return ColorBlue + s + ColorReset }

func fillMessage(msg string) string {
	if len(msg) >= MinMessageWidth {
		return msg
	}
	return msg + strings.Repeat(".", MinMessageWidth-len(msg))
}

type coloredSlogHandler struct {
	slog.Handler
	Output *os.File
}

// isNoColor checks if colored logging is disabled via NO_COLOR env var
func (h *coloredSlogHandler) isNoColor() bool { return os.Getenv("NO_COLOR") != "" }

func (h *coloredSlogHandler) Handle(ctx context.Context, r slog.Record) error {
	if !h.Enabled(ctx, r.Level) {
		// Skip disabled log levels
		return nil
	}
	if h.isNoColor() {
		return h.Handler.Handle(ctx, r)
	}

	var levelStr string
	// Use emojis for levels
	switch r.Level {
	case slog.LevelDebug:
		levelStr = b("🪲")
	case slog.LevelInfo:
		levelStr = b("ℹ️ ")
	case slog.LevelWarn:
		levelStr = b("⚠️")
	case slog.LevelError:
		levelStr = b("❌")
	default:
		levelStr = r.Level.String()
	}

	var source string
	if r.PC != 0 {
		// use runtime.CallersFrames to get function name
		frames := runtime.CallersFrames([]uintptr{r.PC, r.PC - 1})
		for {
			frame, more := frames.Next()
			if !more {
				break
			}
			source = fmt.Sprintf("%s:%d", frame.File, frame.Line)
		}
	}

	// key-value attrs attached to the log record
	var attrs []string
	r.Attrs(func(attr slog.Attr) bool {
		// Skip source if already included
		if attr.Key == slog.SourceKey && source != "" {
			source = attr.Value.String()
			return true
		}
		attrs = append(attrs, b(attr.Key)+"="+grn(fmt.Sprintf("%q", attr.Value.String())))
		return true
	})

	msg := fmt.Sprintf("%s %s %s", dim(r.Time.Format(TimeFormat)), b(levelStr), b(fillMessage(r.Message)))

	if source != "" {
		msg += fmt.Sprintf(" %s%s", SourceEmoji, blu(ul(source)))
	}
	if len(attrs) > 0 {
		msg += dim(fmt.Sprintf(" %s %s", AttrEmoji, strings.Join(attrs, " ")))
	}

	_, err := fmt.Fprintln(h.Output, msg)
	return err
}

func SetupColoredSlogLogging() {
	if os.Getenv("NO_COLOR") != "" {
		slog.Debug("Colored logging disabled via NO_COLOR, keeping default slog handler")
		return
	}
	debugMode := os.Getenv("DEBUG") != ""
	level := slog.LevelInfo
	if debugMode {
		level = slog.LevelDebug
	}
	opts := &slog.HandlerOptions{
		AddSource: debugMode,
		Level:     level,
	}
	baseHandler := slog.NewTextHandler(os.Stderr, opts)
	cl := &coloredSlogHandler{baseHandler, os.Stderr}
	slog.SetDefault(slog.New(cl))
}
