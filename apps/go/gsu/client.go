package gsu

import (
	"context"
	"log/slog"
	"time"

	"cloud.google.com/go/storage"
	"google.golang.org/api/impersonate"
	"google.golang.org/api/option"
)

func Connect(impersonateSA string) (*storage.Client, error) {
	if impersonateSA == "" {
		return simpleClient()
	} else {
		return impersonatedClient(impersonateSA)
	}
}

func simpleClient() (*storage.Client, error) {
	ctx := context.Background()
	client, err := storage.NewClient(ctx)
	if err != nil {
		return nil, err

	}
	return client, nil
}

func impersonatedClient(impersonateSA string) (*storage.Client, error) {
	ctx := context.Background()
	imp := impersonate.CredentialsConfig{
		TargetPrincipal: impersonateSA,
		Scopes:          []string{storage.ScopeReadWrite},
		Lifetime:        time.Hour * 1,
	}

	slog.Info("impersonating", "serviceAccount", impersonateSA, "scopes", imp.Scopes)

	ts, err := impersonate.CredentialsTokenSource(ctx, imp)
	if err != nil {
		return nil, err
	}
	opt := option.WithTokenSource(ts)

	client, err := storage.NewClient(ctx, opt)
	if err != nil {
		return nil, err
	}
	return client, nil
}
