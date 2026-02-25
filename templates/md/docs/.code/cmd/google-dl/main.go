// google-dl downloads content from Google Workspace (Docs, Sheets, Slides)
// and prints it to stdout or writes it to a file.
//
// Usage:
//
//	google-dl read  <url>             # print exported content to stdout
//	google-dl copy  <url> <dest>      # write exported content to dest path
//
// Auth: uses Application Default Credentials (ADC) by default.
// Override with --credentials <path-to-service-account.json>
// or set GOOGLE_CREDENTIALS env var.
package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"golang.org/x/oauth2/google"
	"google.golang.org/api/drive/v3"
	"google.golang.org/api/option"
)

const (
	mimeMarkdown = "text/markdown"
	mimePlain    = "text/plain"
	mimeCSV      = "text/csv"
)

var docIDPattern = regexp.MustCompile(`/d/([a-zA-Z0-9_-]+)`)

func main() {
	credentials := flag.String("credentials", os.Getenv("GOOGLE_CREDENTIALS"),
		"path to service account JSON (default: $GOOGLE_CREDENTIALS or ADC)")
	format := flag.String("format", "", "export format override: markdown, text, csv")
	flag.Usage = usage
	flag.Parse()

	args := flag.Args()
	if len(args) < 2 {
		usage()
		os.Exit(1)
	}

	cmd, url := args[0], args[1]
	if cmd != "read" && cmd != "copy" {
		fmt.Fprintf(os.Stderr, "unknown command: %s\n", cmd)
		usage()
		os.Exit(1)
	}

	if cmd == "copy" && len(args) < 3 {
		fmt.Fprintln(os.Stderr, "copy requires a destination path")
		usage()
		os.Exit(1)
	}

	fileID, err := extractFileID(url)
	if err != nil {
		fatalf("cannot parse file ID from URL: %v", err)
	}

	ctx := context.Background()
	svc, err := newDriveService(ctx, *credentials)
	if err != nil {
		fatalf("failed to create Drive service: %v", err)
	}

	mimeType, err := resolveMIME(ctx, svc, fileID, *format)
	if err != nil {
		fatalf("failed to resolve MIME type: %v", err)
	}

	resp, err := svc.Files.Export(fileID, mimeType).Download()
	if err != nil {
		fatalf("export failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		fatalf("export returned HTTP %d: %s", resp.StatusCode, string(body))
	}

	switch cmd {
	case "read":
		if _, err := io.Copy(os.Stdout, resp.Body); err != nil {
			fatalf("failed to write output: %v", err)
		}
	case "copy":
		dest := args[2]
		if err := writeFile(dest, resp.Body); err != nil {
			fatalf("failed to write file: %v", err)
		}
		fmt.Fprintf(os.Stderr, "written to %s\n", dest)
	}
}

// extractFileID parses the Google Drive file ID from a Workspace URL.
func extractFileID(url string) (string, error) {
	m := docIDPattern.FindStringSubmatch(url)
	if len(m) < 2 {
		return "", fmt.Errorf("no file ID found in %q", url)
	}
	return m[1], nil
}

// resolveMIME determines the export MIME type. If --format is set it is used
// directly; otherwise the Drive API is queried for the file's MIME type and a
// sensible default is chosen.
func resolveMIME(ctx context.Context, svc *drive.Service, fileID, format string) (string, error) {
	if format != "" {
		return formatToMIME(format), nil
	}

	meta, err := svc.Files.Get(fileID).Fields("mimeType").SupportsAllDrives(true).Context(ctx).Do()
	if err != nil {
		return "", err
	}

	switch {
	case strings.Contains(meta.MimeType, "spreadsheet"):
		return mimeCSV, nil
	default:
		return mimeMarkdown, nil
	}
}

func formatToMIME(f string) string {
	switch strings.ToLower(f) {
	case "csv":
		return mimeCSV
	case "text", "txt":
		return mimePlain
	default:
		return mimeMarkdown
	}
}

// newDriveService creates an authenticated Drive v3 service.
func newDriveService(ctx context.Context, credentialsPath string) (*drive.Service, error) {
	var opts []option.ClientOption

	if credentialsPath != "" {
		data, err := os.ReadFile(credentialsPath)
		if err != nil {
			return nil, fmt.Errorf("reading credentials file: %w", err)
		}
		creds, err := google.CredentialsFromJSON(ctx, data, drive.DriveReadonlyScope)
		if err != nil {
			return nil, fmt.Errorf("parsing credentials: %w", err)
		}
		opts = append(opts, option.WithCredentials(creds))
	} else {
		// Fall back to Application Default Credentials
		opts = append(opts, option.WithScopes(drive.DriveReadonlyScope))
	}

	return drive.NewService(ctx, opts...)
}

func writeFile(dest string, r io.Reader) error {
	if err := os.MkdirAll(filepath.Dir(dest), 0o755); err != nil {
		return err
	}
	f, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer f.Close()
	_, err = io.Copy(f, r)
	return err
}

func fatalf(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "error: "+format+"\n", args...)
	os.Exit(1)
}

func usage() {
	fmt.Fprintln(os.Stderr, `Usage:
  google-dl [flags] read  <url>          export to stdout
  google-dl [flags] copy  <url> <dest>   export to file

Flags:`)
	flag.PrintDefaults()
}
