package main

import (
	"fmt"
	"log/slog"
	"os"
	"strings"
	"time"

	vscode "codeberg.org/ubunatic/vscode/pkg"
)

func fail(err error, msg string, args ...any) {
	slog.With(args...).Error(msg, "error", err)
	os.Exit(1)
}

func setupLogging() {
	if os.Getenv("DEBUG") != "" {
		slog.SetLogLoggerLevel(slog.LevelDebug)
	}
}

func backupFile(file string) error {
	now := time.Now().Unix()
	backup := fmt.Sprintf("%s.bak.%d", file, now)
	return os.Rename(file, backup)
}

func main() {
	setupLogging()

	files := os.Args[1:]
	if len(files) < 2 || len(files) > 3 {
		fail(nil, "usage: merge <file1> <file2> [output-file]", "args", os.Args)
	}

	res, err := vscode.MergedKeybindings(files[0], files[1])
	if err != nil {
		fail(err, "failed to merge keybindings", "file1", files[0], "file2", files[1])
	}

	// Create output file only after successful read and merge.
	// This allows to write the merged keybindings in place.
	output := os.Stdout
	if len(files) == 3 {
		err := backupFile(files[2])
		if err != nil {
			fail(err, "failed to backup file", "file", files[0])
		}

		output, err = os.Create(files[2])
		if err != nil {
			fail(err, "failed to create output file", "file", files[2])
		}
		defer output.Close()
	}

	slog.Info("writing merged keybindings", "output", output.Name())
	_, err = output.Write(res.Contents)
	if err != nil {
		fail(err, "failed to write output file", "file", files[2])
	}

	if len(res.Duplicates) > 0 {
		slog.Warn("found duplicate keybindings", "count", len(res.Duplicates))
		for _, dup := range res.Duplicates {
			slog.Debug("duplicate keybinding",
				"key", dup.KeyString(),
				"when", dup.When,
				"command", dup.Command,
				"source", strings.TrimSpace(dup.CommentString("")),
			)
		}
	}
}
