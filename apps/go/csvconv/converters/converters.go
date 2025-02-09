package converters

import (
	"regexp"
	"strconv"
	"strings"
)

type Converter func(records Records) (Records, error)

type Records [][]string

func CutHeadersConverter(n int64) Converter {
	return func(records Records) (Records, error) {
		return CutHeaders(n, records)
	}
}

func CutHeaders(n int64, records Records) (Records, error) {
	if n <= 0 {
		return records, nil
	}

	if n >= int64(len(records)) {
		return nil, nil
	}

	return records[n:], nil
}

func NumberSeparatorsConverter(srcSep, dstSep rune) Converter {
	return func(records Records) (Records, error) {
		return ChangeNumberSeparators(srcSep, dstSep, records)
	}
}

func ChangeNumberSeparators(srcSep, dstSep rune, records Records) (Records, error) {
	for i, record := range records {
		for j, field := range record {
			ok := IsNumber(srcSep, field)
			if !ok {
				continue
			}
			records[i][j] = ReplaceSeparator(srcSep, dstSep, field)
		}
	}
	return records, nil
}

func CleanNumbersConverter(srcSep rune) Converter {
	return func(records Records) (Records, error) {
		return CleanNumbers(srcSep, records)
	}
}

func CleanNumbers(srcSep rune, records Records) (Records, error) {
	for i, record := range records {
		for j, field := range record {
			clean, ok := CleanNumber(srcSep, field)
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
func CleanNumber(srcSep rune, field string) (decimal string, ok bool) {
	if !IsNumber(srcSep, field) {
		return "", false
	}
	switch srcSep {
	case ',': // remove all dot formatting from comma-separated number
		field = strings.ReplaceAll(field, ".", "")
		number := ReplaceSeparator(',', '.', field) // make it valid for ParseFloat
		_, err := strconv.ParseFloat(number, 64)
		if err != nil {
			panic(err) // should not happen, because IsNumber was true
		}
		return field, true
	case '.': // remove all comma formatting from dot-separated number (should be a valid number already)
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

func ReplaceSeparator(srcSep, dstSep rune, value string) string {
	parts := strings.Split(value, string(srcSep))
	for i, part := range parts {
		parts[i] = strings.ReplaceAll(part, string(dstSep), string(srcSep))
	}
	return strings.Join(parts, string(dstSep))
}

var (
	expDotFracNumber   = regexp.MustCompile(`^-?[0-9]{0,3}((,[0-9]{3})*|[0-9]*)(\.|\.\d+)?$`)
	expCommaFracNumber = regexp.MustCompile(`^-?[0-9]{0,3}((\.[0-9]{3})*|[0-9]*)(,|,\d+)?$`)
)

func IsNumber(srcSep rune, field string) bool {
	if field == "" || field == "." || field == "," {
		return false
	}
	if srcSep == '.' {
		return expDotFracNumber.MatchString(field)
	}
	if srcSep == ',' {
		return expCommaFracNumber.MatchString(field)
	}
	return false
}
