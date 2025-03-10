package converters

import (
	"errors"
	"log/slog"
	"regexp"
	"slices"
	"strconv"
	"strings"
)

type NumberFormat string

const (
	NumberInvalid NumberFormat = ""
	NumberComma   NumberFormat = "comma"
	NumberDot     NumberFormat = "dot"
)

func (f NumberFormat) Sep() rune {
	switch f {
	case NumberComma:
		return ','
	case NumberDot:
		return '.'
	default:
		return 0
	}
}

func (f NumberFormat) Fmt() rune {
	switch f {
	case NumberComma:
		return '.'
	case NumberDot:
		return ','
	default:
		return 0
	}
}

var ErrInvalidNumber = errors.New("invalid number")

var ErrInvalidNumberFormat = errors.New("invalid number format")

func MustParseNumberFormat(s string) NumberFormat { return MustParse(s, ParseNumberFormat) }
func ParseNumberFormat(s string) (NumberFormat, error) {
	s = strings.TrimSpace(strings.ToLower(s))
	switch s {
	case "comma", ",":
		return NumberComma, nil
	case "dot", ".":
		return NumberDot, nil
	default:
		return NumberInvalid, ErrInvalidNumberFormat
	}
}

func CleanNumbers(records Records, fmt NumberFormat) (Records, error) {
	for i, record := range records {
		for j, field := range record {
			clean, ok := CleanNumber(field, fmt)
			if !ok {
				continue
			}
			records[i][j] = clean
		}
	}
	return records, nil
}

// CleanNumber removes formatting characters "." or "," from a number string.
// And returns the cleaned number string if the input is a valid number for the given separator.
func CleanNumber(field string, fmt NumberFormat) (string, bool) {
	if !IsNumber(field, fmt) {
		return "", false
	}
	switch fmt {
	case NumberComma: // remove all dot formatting from comma-separated number
		field = strings.ReplaceAll(field, ".", "")
		number := ReplaceSeparator(field, ',', '.') // make it valid for ParseFloat
		_, err := strconv.ParseFloat(number, 64)
		if err != nil {
			panic(err) // should not happen, because IsNumber was true
		}
		return field, true
	case NumberDot: // remove all comma formatting from dot-separated number (should be a valid number already)
		field = strings.ReplaceAll(field, ",", "")
		_, err := strconv.ParseFloat(field, 64)
		if err != nil {
			panic(err) // should not happen, because IsNumber was true
		}
		return field, true
	default:
		return "", false
	}
}

func ReplaceSeparator(value string, srcSep, dstSep rune) string {
	if srcSep == 0 || dstSep == 0 {
		return value
	}
	parts := strings.Split(value, string(srcSep))
	for i, part := range parts {
		parts[i] = strings.ReplaceAll(part, string(dstSep), string(srcSep))
	}
	return strings.Join(parts, string(dstSep))
}

func ConvertNumber(records Records, column string, from, to NumberFormat) (Records, error) {
	idx, err := records.Columns(column)
	if err != nil {
		return nil, err
	}
	if len(idx) != 1 {
		return nil, ErrInvalidColumnIndex
	}
	return convertNumber(records, idx[0], from, to)
}

func ConvertNumbers(records Records, from, to NumberFormat) (Records, error) {
	result := Records{}
	for _, record := range records {
		newRecord := make([]string, len(record))
		for j, field := range record {
			slog.Debug("try converting number", "number", field, "from", from, "to", to)
			if IsNumber(field, from) {
				repl := ReplaceSeparator(field, from.Sep(), to.Sep())
				slog.Debug("converted number", "number", field, "from", from, "to", to, "result", repl)
				newRecord[j] = repl
			} else {
				newRecord[j] = field
			}
		}
		result = append(result, newRecord)
	}
	return result, nil
}

func convertNumber(records Records, col Column, from, to NumberFormat) (Records, error) {
	result := records.Header().Clone()
	for _, record := range records.Data() {
		if len(record) <= col.Index {
			// unset field, keep the row as is
			result = append(result, record)
			continue
		}
		val := Unquote(record[col.Index])
		if val == "" {
			// empty field, keep the row as is
			result = append(result, record)
			continue
		}

		if !IsNumber(val, from) {
			slog.Error("invalid number", "number", record[col.Index])
			return nil, ErrInvalidNumber
		}
		slog.Debug("converting number", "number", val, "from", from, "to", to)

		newRecord := slices.Clone(record)
		newRecord[col.Index] = ReplaceSeparator(val, from.Sep(), to.Sep())
		result = append(result, newRecord)
	}
	return result, nil
}

var (
	expDotFracNumber   = regexp.MustCompile(`^[-+]?[0-9]{0,3}((,[0-9]{3})*|[0-9]*)(\.|\.\d+)?$`)
	expCommaFracNumber = regexp.MustCompile(`^[-+]?[0-9]{0,3}((\.[0-9]{3})*|[0-9]*)(,|,\d+)?$`)
)

func IsNumber(field string, srcSep NumberFormat) bool {
	if field == "" || field == "." || field == "," {
		return false
	}
	if srcSep == NumberDot {
		return expDotFracNumber.MatchString(field)
	}
	if srcSep == NumberComma {
		return expCommaFracNumber.MatchString(field)
	}
	return false
}

func ToFloat(field string) float64 {
	if field == "" || field == "." || field == "," {
		return 0
	}

	n, err := strconv.ParseFloat(field, 64)
	if err != nil {
		panic("invalid number: " + field + ", error:" + err.Error())
	}
	return n
}
