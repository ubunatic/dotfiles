package csvconv

import (
	"errors"
	"log/slog"
	"strings"

	"github.com/urfave/cli/v2"
	"ubunatic.com/dotapps/go/csvconv/converters"
	"ubunatic.com/dotapps/go/csvconv/csvlang"
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
			&cli.BoolFlag{
				Name:    "inline",
				Aliases: []string{"i"},
				Usage:   "Inline edit (overwrite src, dst must be empty)",
				Value:   false,
			},
			&cli.StringFlag{
				Name:     "input",
				Aliases:  []string{"f"},
				Usage:    "Input file",
				Value:    "",
				Required: true,
			},
			&cli.StringFlag{
				Name:    "output",
				Aliases: []string{"o"},
				Usage:   "Output file",
				Value:   "",
			},
			&cli.StringFlag{
				Name:    "newline",
				Aliases: []string{"n"},
				Usage:   "Output newline mode (auto, nl, crlf)",
				Value:   "auto",
			},
			&cli.StringFlag{
				Name:    "delim",
				Aliases: []string{"d"},
				Usage:   "Delimiter for src/dst (can be set separately or together, e.g. -d ',;' | -d ',')",
				Value:   ",",
			},
		},
		Args:      true,
		ArgsUsage: "src [dst]  # no more flags after this",
		Description: join(
			"query...  # CSV transformation language",
			"Examples:",
			"   'select a,b,c'                       select columns by name",
			"   'select 1,2,3'                       select columns by index",
			"   'select a,b | filter a = 1'          filter rows by value",
			"   'select a,b | filter a ~ \"[0-9]\"'  filter rows by regex",
			"   'select a,b | sort a'                sort rows by string value",
			"   'select a,b | sort:num a'            sort rows by number value",
			"   'select a,b | sort:num:desc a'       sort rows by number value descending",
			"   'select a,b | number:dot a'          convert string to number",
			"   'select a,b | date:iso a'            convert date to ISO format",
			"   'select a,b | numbers dot'           convert all numbers",
			"   'select a,b | dates iso'             convert all dates",
		),
		Suggest:              true,
		EnableBashCompletion: true,
		HideVersion:          true,
		Action: func(ctx *cli.Context) error {
			setupLevel(ctx.Bool("verbose"))
			query := ctx.Args().Slice()
			inline := ctx.Bool("inline")
			src := ctx.String("input")
			dst := ctx.String("output")
			delim := ctx.String("delim")
			dstDelim := delim

			errs := []string{}

			if len(delim) > 1 {
				delims := strings.Split(delim, "")
				delim = delims[0]
				if len(delims) != 2 {
					errs = append(errs, "delimiter must be a single character or a pair of characters")
				} else {
					dstDelim = delims[1]
				}
			}

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

			mode, modeErr := ParseNLMode(ctx.String("nl"))
			if modeErr != nil {
				errs = append(errs, "invalid output mode")
			}

			if len(errs) > 0 {
				for _, err := range errs {
					slog.Error("Argument Error", "error", err)
				}
				return errors.New("invalid arguments")
			}

			statements := csvlang.Parse(query...)

			convs := []converters.Converter{}
			for _, stmt := range statements {
				convs = append(convs, stmt.Converter())
			}

			err := ConvertCsv(
				src, dst,
				WithDelimiters(rune(delim[0]), rune(dstDelim[0])),
				WithOutputMode(mode),
				WithInline(inline),
				With(convs...),
			)
			if err != nil {
				slog.Error("Conversion Error", "error", err)
				return cli.Exit("Conversion failed", 1)
			}
			return nil
		},
	}
}
