package hiccupwatch

// AI Instructions
// ---------------
// Related files: ../main.go, ./watch.go
//
// Goal:
//   Detect GNOME Shell/Wayland hiccups (small freezes)
//   Strategy:
//   1. collect journalctl for 'mutter|kwin|gnome-shell|wayland'
//   2. collect dmesg
//   3. collect atop output
//   4. record this system data in a sliding window of 5min
//   5. if I see a hiccup (manually), stop the script and save the data to a file
//   file format (plain text):
//   timestamp (seconds) | journalctl | dmesg | atop
//   file format (json rows):
//   { "timestamp": seconds, "journalctl": "...", "dmesg": "...", "atop": "..." }
//
//   Implementation notes:
//   - use Go and slog.Logger with JSON handler to record data
//   - show a simple log counter terminal UI output:
//     "hiccupwatch: 12345 lines recorded (journalctl: 1678 lines, dmesg: 1234 lines, atop: 5678 lines)"
//
// Requirements:
//   - journalctl
//   - dmesg
//   - atop
//   - Go 1.24+
