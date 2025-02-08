package csvconv

import (
	"log/slog"
	"os"
)

func ConvertCsv(src, dst string, opts ...Opt) error {
	o := newOptions(opts...)

	if src == "-" {
		src = os.Stdin.Name()
	}

	if o.inline && dst != "" {
		dst = src
	}

	if dst == "" {
		dst = os.Stdout.Name()
	}

	slog.Debug("Converting csv file", "src", src, "dst", dst,
		"delimiters", []rune{o.srcDelimiter, o.dstDelimiter},
		"outputMode", o.outputMode,
	)

	data, nlMode, err := ReadFileRaw(src)
	records, err := ReadCsv(o.srcDelimiter, data)
	if err != nil {
		return err
	}

	slog.Debug("Read csv file", "records", len(records), "nlMode", nlMode)
	for _, rec := range records {
		slog.Debug("Record", "record", rec)
	}

	for _, converter := range o.converters {
		records, err = converter(records)
		if err != nil {
			return err
		}
	}

	if o.outputMode != AutoCRLF {
		nlMode = o.outputMode
	}

	slog.Debug("Converted records", "records", len(records), "nlMode", nlMode)

	data, err = WriteCsv(o.dstDelimiter, nlMode, records)
	if err != nil {
		return err
	}

	err = WriteFileRaw(dst, data)
	if err != nil {
		return err
	}

	return nil
}
