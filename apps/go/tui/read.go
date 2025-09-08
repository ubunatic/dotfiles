// DEMO CODE!
// This is for learning purposes only.
// It is incomplete and may not cover many edge cases.

package tui

import (
	"fmt"
	"os"
	"syscall"
)

// KeyPress holds the data for a single key press event.
type KeyPress struct {
	Keycode int
	Char    string
}

// ReadKeycode reads raw key input from the terminal and returns a channel
// that streams KeyPress events. It also manages the terminal's raw mode.
// The channel is closed when the 'Esc' key is pressed.
func ReadKeycode(file *os.File) (<-chan KeyPress, error) {

	// Create a buffered channel to send key press data.
	keypressChan := make(chan KeyPress, 1)

	// Use a goroutine to handle the terminal reading in the background.
	go func() {
		defer close(keypressChan)
		// Ensure the terminal state is restored when the function exits.
		// This is now handled within the library function itself.

		var buf [1]byte
		var seq []byte
		for {
			n, err := file.Read(buf[:])
			if err != nil {
				// Handle interrupted system calls (like Ctrl+C).
				if opErr, ok := err.(*os.PathError); ok && opErr.Err == syscall.EINTR {
					continue
				}
				fmt.Fprintf(os.Stderr, "Error reading key: %v\n", err)
				return
			}

			if n > 0 {
				b := buf[0]
				keycode := int(b)
				esc := len(seq) == 1 && int(seq[0]) == 27

				// This is just the bare minimum to detect.
				// There are 100s of more edge cases to consider.
				switch keycode {
				case 3, 4:
					return
				case 27:
					// record esc seq
					seq = append(seq, b)
				default:
					if esc {
						switch keycode {
						case 91: // arrow keys
							seq = append(seq, b)
							continue
						}
					}
					seq = append(seq, b)
					// Create the KeyPress event and send it to the channel.
					keypress := KeyPress{
						Keycode: keycode,
						Char:    string(seq),
					}
					keypressChan <- keypress
					seq = nil
				}
			}
		}
	}()

	return keypressChan, nil
}
