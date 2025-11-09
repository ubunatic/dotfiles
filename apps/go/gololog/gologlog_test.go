package gololog_test

import (
	"log/slog"
	"strings"
	"testing"
	"time"

	"ubunatic.com/dotapps/go/gololog"
)

func TestMain(m *testing.M) {
	gololog.SetupColoredSlogLogging()
	m.Run()
}

func Test_MessageWidth(t *testing.T) {
	lens := []int{
		10, 20, 30, 40, // grow slowly
		40, 10, 5, 0, // shrink faster
		50, 70, 90, 120, // grow bigger
		90, 1, 90, 1, // oscillate
	}
	logsPerLen := 10

	words := strings.Split("Test log with some short text. "+
		"Add a bit of more text to grow out the log width. "+
		"Add some very long text to see if all text is shown nicely. "+
		"Not sure if we need this much text, but we add it anyway.", " ")

	prevLen := lens[0]
	for _, nextLen := range lens {
		inc := 1
		if nextLen < prevLen {
			inc = -1 * ((prevLen - nextLen) / logsPerLen)
		} else {
			inc = (nextLen - prevLen) / logsPerLen
		}
		// defne starting length with some jitter
		l := prevLen
		// start growth or shrinkage from previous length
		for i := 0; i < logsPerLen; i++ {
			l += inc
			l += time.Now().Nanosecond()%10 - 5 // add some jitter
			l = max(1, l)
			switch {
			case l < 0:
				l = 0
			case l >= nextLen:
				l = nextLen
			}
			msg := words[0]
			i := 1
			// build message of desired length, word-by-word (may exceed length a bit)
			for len(msg) < l {
				msg += " " + words[i%len(words)]
				i++
			}
			slog.Info(msg, "p", prevLen, "t", nextLen, "a", len(msg))
		}
		prevLen = nextLen
	}
}

func Test_ColoredLogging(t *testing.T) {
	slog.Debug("This is a debug message", "key1", "value1")
	slog.Info("This is an info message", "key2", 42)
	slog.Warn("This is a warning message", "key3", 3.14)
	slog.Error("This is an error message", "key4", "error details")
	slog.Info("Test message with source", "obj", t)
	slog.Info("Short msg", "duration", 123*time.Millisecond)
	slog.Info("Message", "time", time.Now())
	slog.Info("Test message with many attributes",
		"string", "value",
		"int", 123,
		"float", 3.14159,
		"bool", true,
		"another_string", "another value",
	)
}
