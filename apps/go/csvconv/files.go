package csvconv

import (
	"bytes"
	"encoding/csv"
	"errors"
	"os"
	"strings"

	"ubunatic.com/dotapps/go/csvconv/converters"
)

type NLMode string

const (
	AutoCRLF  NLMode = ""
	NoUseCRLF NLMode = "NL"
	UseCRLF   NLMode = "CRLF"
)

func (nl NLMode) Delim() string {
	if nl == UseCRLF {
		return "\r\n"
	}
	return "\n"
}

var ErrInvalidNLMode = errors.New("invalid newline mode")

func MustParseNLMode(s string) NLMode { return converters.MustParse(s, ParseNLMode) }
func ParseNLMode(s string) (NLMode, error) {
	s = strings.ToUpper(s)
	switch s {
	case "NL", "\n":
		return NoUseCRLF, nil
	case "CRLF", "\r\n":
		return UseCRLF, nil
	case "AUTO", "ANY", "":
		return AutoCRLF, nil
	default:
		return AutoCRLF, ErrInvalidNLMode
	}
}

func ReadFileRaw(src string) ([]byte, NLMode, error) {
	data, err := os.ReadFile(src)
	if err != nil {
		return nil, NoUseCRLF, err
	}
	nl := DetectNewline(data)
	return data, nl, nil
}

func WriteFileRaw(dst string, data []byte) error {
	return os.WriteFile(dst, data, 0o644)
}

func ReadFile(src string) ([]string, NLMode, error) {
	data, nl, err := ReadFileRaw(src)
	if err != nil {
		return nil, NoUseCRLF, err
	}
	lines := strings.Split(string(data), nl.Delim())
	return lines, nl, nil
}

func WriteFile(dst string, dstNL NLMode, lines []string) error {
	f, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer f.Close()

	for _, line := range lines {
		_, err := f.WriteString(line + dstNL.Delim())
		if err != nil {
			return err
		}
	}
	return nil
}

func DetectNewline(data []byte) NLMode {
	switch {
	case strings.Contains(string(data), "\r\n"):
		return UseCRLF
	case strings.Contains(string(data), "\n"):
		return NoUseCRLF
	default:
		return AutoCRLF
	}
}

func ReadCsv(delimiter rune, data []byte) ([][]string, error) {
	r := csv.NewReader(bytes.NewReader(data))
	r.Comma = delimiter
	r.LazyQuotes = true    // do not allow quotes in fields
	r.FieldsPerRecord = -1 // allow variable number of fields

	records, err := r.ReadAll()
	if err != nil {
		return nil, err
	}
	return records, nil
}

func WriteCsv(delimiter rune, nl NLMode, records [][]string) ([]byte, error) {
	var buf bytes.Buffer
	w := csv.NewWriter(&buf)
	w.Comma = delimiter
	w.UseCRLF = nl == UseCRLF
	w.WriteAll(records)
	w.Flush()
	return buf.Bytes(), w.Error()
}
