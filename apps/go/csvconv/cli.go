package csvconv

import (
	"errors"
	"log/slog"
	"strings"

	"github.com/urfave/cli/v2"
	"ubunatic.com/dotapps/go/csvconv/converters"
)

func join(lines ...string) string {
	return strings.Join(lines, "\n")
}

func setupLevel(verbose bool) {
	if verbose {
		slog.SetLogLoggerLevel(slog.LevelDebug)
		slog.Debug("Verbose mode enabled")
	}
}

func App() *cli.App {
	return &cli.App{
		Name:     "DotApp: CSV Converter",
		Usage:    "Convert CSV files",
		HelpName: "csvconv",
		Flags: []cli.Flag{
			&cli.BoolFlag{
				Name:    "verbose",
				Aliases: []string{"v"},
				Usage:   "Verbose output",
				Value:   false,
			},
			&cli.StringFlag{
				Name:    "delimiter",
				Aliases: []string{"d"},
				Usage:   "Delimiter",
				Value:   ",",
			},
			&cli.StringFlag{
				Name:    "dst-delimiter",
				Aliases: []string{"D"},
				Usage:   "Destination delimiter (default is source delimiter)",
			},
			&cli.StringFlag{
				Name:    "dst-newline",
				Aliases: []string{"n"},
				Usage:   "Output mode: auto, nl, crlf",
				Value:   "auto",
			},
			&cli.BoolFlag{
				Name:    "inline",
				Aliases: []string{"i"},
				Usage:   "Inline edit (overwrite src, dst must be empty)",
				Value:   false,
			},
			&cli.Int64Flag{
				Name:    "cut-headers",
				Aliases: []string{"H"},
				Usage:   "Remove headers lines (first N lines)",
				Value:   0,
			},
		},
		Args:      true,
		ArgsUsage: "src [dst]  # no more flags after this",
		Description: join(
			"src    Source CSV file (required, use - for stdin)",
			"dst    Destination CSV file (optional, default is stdout)",
		),
		DefaultCommand:       "convert",
		Suggest:              true,
		EnableBashCompletion: true,
		HideVersion:          true,
		Commands: []*cli.Command{
			{
				Name:  "convert",
				Usage: "Convert CSV files",
				Action: func(ctx *cli.Context) error {
					setupLevel(ctx.Bool("verbose"))

					src := ctx.Args().Get(0)
					dst := ctx.Args().Get(1)
					inline := ctx.Bool("inline")
					delim := ctx.String("delimiter")
					dstDelim := ctx.String("dst-delimiter")
					if dstDelim == "" {
						dstDelim = delim
					}
					headers := ctx.Int64("cut-headers")

					errs := []string{}

					if src == "-" && inline {
						errs = append(errs, "stdin cannot be used with inline")
					}
					if src == "" {
						errs = append(errs, "src is required")
					}
					if inline && dst != "" {
						errs = append(errs, "dst cannot be used with inline")
					}
					if len(delim) != 1 {
						errs = append(errs, "delimiter must be a single character")
					}
					if len(dstDelim) != 1 {
						errs = append(errs, "destination delimiter must be a single character")
					}

					mode, modeErr := ParseNLMode(ctx.String("dst-newline"))
					if modeErr != nil {
						errs = append(errs, "invalid output mode")
					}

					if len(errs) > 0 {
						for _, err := range errs {
							slog.Error("Argument Error", "error", err)
						}
						return errors.New("invalid arguments")
					}

					err := ConvertCsv(
						src, dst,
						WithDelimiters(rune(delim[0]), rune(dstDelim[0])),
						WithOutputMode(mode),
						WithInline(inline),
						With(converters.CutHeadersConverter(headers)),
					)
					if err != nil {
						slog.Error("Conversion Error", "error", err)
						return cli.Exit("Conversion failed", 1)
					}
					return nil
				},
			},
		},
	}
}
