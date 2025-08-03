package main

import (
	"context"
	"time"

	"fmt"
	"log/slog"
	"os"
	"strings"

	"cloud.google.com/go/storage"
	"github.com/spf13/cobra"
	"google.golang.org/api/iterator"
	"ubunatic.com/dotapps/go/gsu"
	"ubunatic.com/dotapps/go/tui"
)

func main() {
	ctx := context.Background()

	var app = &cobra.Command{
		Use:   "gsu",
		Short: "gsutil-like command-line tool for interacting with Google Cloud Storage, but with impersonation support.",
	}

	var impersonateSA string
	var timeout time.Duration

	app.PersistentFlags().StringVarP(&impersonateSA, "impersonate-service-account", "i", "", "Service Account to impersonate")
	app.PersistentFlags().DurationVarP(&timeout, "timeout", "t", 0, "Timeout for the command")

	if timeout > 0 {
		var cancel context.CancelFunc
		ctx, cancel = context.WithTimeout(ctx, timeout)
		defer cancel()
	}

	app.AddCommand(&cobra.Command{
		Use:   "ls",
		Short: "List buckets",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			bucket, object, err := ParseURL(args[0])
			if err != nil {
				slog.Error("Failed to parse URL", "error", err)
				return gsu.ErrBadArguments
			}
			client, err := gsu.Connect(impersonateSA)
			if err != nil {
				slog.Error("Failed to connect", "error", err)
				return gsu.ErrConnectFailed
			}

			slog.Info("ls", "bucket", bucket, "object", object)

			it := client.Bucket(bucket).Objects(ctx, &storage.Query{
				Prefix: object,
			})

			for {
				objAttrs, err := it.Next()
				if err == iterator.Done {
					break
				}
				if err == storage.ErrBucketNotExist {
					return gsu.ErrNotFound
				}
				if err != nil {
					slog.Error("Failed to list objects", "error", err)
					return gsu.ErrLsFailed
				}
				echo(objAttrs.Name)
			}
			return nil
		},
	})

	app.AddCommand(&cobra.Command{
		Use:   "rm",
		Short: "Remove object",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			bucket, object, err := ParseURL(args[0])
			if err != nil {
				slog.Error("Failed to parse URL", "error", err)
				return gsu.ErrBadArguments
			}
			client, err := gsu.Connect(impersonateSA)
			if err != nil {
				slog.Error("Failed to connect", "error", err)
				return gsu.ErrConnectFailed
			}

			err = tui.Confirm("Delete", object, "in bucket", bucket)
			if err != nil {
				return gsu.ErrRmAborted
			}

			err = client.Bucket(bucket).Object(object).Delete(ctx)
			if err != nil {
				if err == storage.ErrObjectNotExist {
					return gsu.ErrNotFound
				}
				slog.Error("Failed to delete object", "error", err)
				return gsu.ErrRmFailed
			}
			echo("Deleted", object)
			return nil
		},
	})

	// start app
	if err := app.Execute(); err != nil {
		slog.Error("Failed to execute command", "error", err)
		os.Exit(1)
	}
}

func ParseURL(url string) (string, string, error) {
	// allowed URLs
	// bucket/object
	// gs://bucket/object
	// gs://bucket
	// bucket/
	// bucket

	url = strings.TrimPrefix(url, "gs://")
	parts := strings.Split(url, "/")

	if len(parts) == 1 {
		return parts[0], "", nil
	}
	if len(parts) > 1 {
		return parts[0], strings.Join(parts[1:], "/"), nil
	}
	return "", "", fmt.Errorf("invalid URL: %s", url)
}

func echo(msg ...any) { fmt.Println(msg...) }
