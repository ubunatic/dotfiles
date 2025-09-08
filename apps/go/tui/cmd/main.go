// The main package is the program's entry point.
package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"golang.org/x/term"
	"ubunatic.com/dotapps/go/tui"
)

func main() {
	fmt.Printf("Press a key to see its keycode. Press 'Esc' to exit, or 'Ctrl+C' to terminate.\r\n")

	file := os.Stdin

	// Get the file descriptor for standard input.
	fd := int(file.Fd())

	// Check if the file descriptor is a terminal.
	if !term.IsTerminal(fd) {
		log.Fatalln("not a terminal")
	}

	// Save the current terminal state and put the terminal into raw mode.
	oldState, err := term.MakeRaw(fd)
	if err != nil {
		log.Fatal(err.Error())
	}

	defer func() {
		restoreErr := term.Restore(fd, oldState)
		if restoreErr != nil {
			// This is a rare case, but it's good to log for debugging.
			fmt.Fprintf(os.Stderr, "Warning: Failed to restore terminal state: %v\n", restoreErr)
		}
	}()

	// Set up a channel to listen for OS signals (like Ctrl+C).
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	// Get the channel for key presses from the tui package.
	keypressChan, err := tui.ReadKeycode(file)
	if err != nil {
		fmt.Printf("Application error: %v\r\n", err)
		os.Exit(1)
	}

	// Use a select statement to listen for both keypresses and OS signals.
	for {
		select {
		case keypress, ok := <-keypressChan:
			if !ok {
				// The channel was closed, meaning the 'Esc' key was pressed.
				fmt.Printf("Exiting on Escape key.\r\n")
				return
			}
			// Print the keypress information.
			// Use \r\n to ensure the cursor moves to the start of a new line.
			fmt.Printf("Received: Keycode: %d, Character: %q\r\n", keypress.Keycode, keypress.Char)
		case <-sigChan:
			// A signal (like Ctrl+C) was received.
			fmt.Printf("Exiting on signal.\r\n")
			return
		}
	}
}
