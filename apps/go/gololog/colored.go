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
	TimeFormat              = "2006-01-02 15:04:05.000" // with milliseconds
	MinTargetedMessageWidth = 30                        // minimum width for message filling
	MaxTargetedMessageWidth = 80                        // maximum width for message filling
)

func b(s string) string   { return ColorBold + s + ColorReset }
func ul(s string) string  { return ColorUnderline + s + ColorReset }
func dim(s string) string { return ColorDimmed + s + ColorReset }
func grn(s string) string { return ColorGreen + s + ColorReset }
func blu(s string) string { return ColorBlue + s + ColorReset }
func yel(s string) string { return ColorYellow + s + ColorReset }

type coloredSlogHandler struct {
	avgMsgLen int
	slog.Handler
	Output *os.File
}

// updateMsgLen updates the average message length for formatting purposes.
// It implements a simple 10-line moving average that changes slowly over time.
func (h *coloredSlogHandler) updateMsgLen(msg string) {
	h.avgMsgLen = (h.avgMsgLen*9 + len(msg)) / 10
}

func (h *coloredSlogHandler) targetedMessageWidth() int {
	w := max(MinTargetedMessageWidth, h.avgMsgLen)
	return min(w, MaxTargetedMessageWidth)
}

func (h *coloredSlogHandler) fillMessage(msg string) string {
	h.updateMsgLen(msg)
	w := h.targetedMessageWidth()
	if len(msg) >= w {
		return msg
	}
	return msg + strings.Repeat(".", w-len(msg))
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
		levelStr = b("⚠️ ")
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
		switch attr.Value.Kind() {
		case slog.KindString:
			attrs = append(attrs, attr.Key+"="+grn(fmt.Sprintf("%q", attr.Value.String())))
		case slog.KindInt64, slog.KindUint64:
			attrs = append(attrs, attr.Key+"="+yel(fmt.Sprintf("%d", attr.Value.Int64())))
		case slog.KindFloat64:
			attrs = append(attrs, attr.Key+"="+yel(fmt.Sprintf("%f", attr.Value.Float64())))
		case slog.KindBool:
			attrs = append(attrs, attr.Key+"="+blu(fmt.Sprintf("%t", attr.Value.Bool())))
		case slog.KindDuration:
			attrs = append(attrs, attr.Key+"="+blu(attr.Value.Duration().String()))
		default:
			attrs = append(attrs, attr.Key+"="+grn(fmt.Sprintf("%q", attr.Value.String())))
		}
		return true
	})

	msg := fmt.Sprintf("%s %s %s", dim(r.Time.Format(TimeFormat)), levelStr, h.fillMessage(r.Message))

	attrs = append(attrs, "log_width="+fmt.Sprintf("%d", h.targetedMessageWidth())) // copy to avoid modifying original

	if source != "" {
		msg += fmt.Sprintf(" %s%s", SourceEmoji, blu(ul(source)))
	}
	if len(attrs) > 0 {
		msg += " " // Separator
		if AttrEmoji != "" {
			msg += AttrEmoji + " "
		}
		msg += strings.Join(attrs, " ")
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
	cl := &coloredSlogHandler{0, baseHandler, os.Stderr}
	slog.SetDefault(slog.New(cl))
}
