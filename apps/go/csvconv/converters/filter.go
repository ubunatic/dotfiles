package converters

import (
	"errors"
	"log/slog"
	"regexp"
	"slices"
	"strings"
)

var ErrInvalidColumnIndex = errors.New("invalid column indices")

func Filter(records Records, column, op, value string) (Records, error) {
	indices, err := ColumnIndex(records[0], column)
	if err != nil {
		return nil, err
	}
	if len(indices) != 1 {
		slog.Error("invalid column indices for filter", "indices", indices, "column", column)
		return nil, ErrInvalidColumnIndex
	}
	return filter(records, indices[0], op, value)
}

func filter(records Records, column int, op, value string) (Records, error) {
	result := Records{}
	result = append(result, records[0]) // header
	for _, record := range records[1:] {
		if compare(record[column], value, op) {
			result = append(result, record)
		}
	}
	return result, nil
}

func compare(a, b, op string) bool {
	if IsNumber(a, NumberDot) && IsNumber(b, NumberDot) {
		return compareNumbers(a, b, op)
	}
	if IsNumber(a, NumberComma) && IsNumber(b, NumberComma) {
		panic("numbers must be converted to dot format before comparing")
	}
	return compareStrings(a, b, op)
}

func compareNumbers(a, b, op string) bool {
	fa, fb := ToFloat(a), ToFloat(b)
	switch op {
	case "==", "=", "eq":
		return fa == fb
	case "!=", "<>", "neq":
		return fa != fb
	case "<", "lt":
		return fa < fb
	case "<=", "le", "lte":
		return fa <= fb
	case ">", "gt":
		return fa > fb
	case ">=", "ge", "gte":
		return fa >= fb
	default:
		panic("unknown number operator: " + op)
	}
}

func compareStrings(a, b, op string) bool {
	b = Unquote(b)
	switch op {
	case "==", "=", "eq":
		return a == b
	case "!=", "<>", "neq":
		return a != b
	case "<", "lt":
		return a < b
	case "<=", "le", "lte":
		return a <= b
	case ">", "gt":
		return a > b
	case ">=", "ge", "gte":
		return a >= b
	case "contains":
		return strings.Contains(a, b)
	case "startswith":
		return strings.HasPrefix(a, b)
	case "endswith":
		return strings.HasSuffix(a, b)
	case "like":
		b = strings.ReplaceAll(b, ".", "\\.") // escape dots
		pattern := "^" + strings.ReplaceAll(b, "%", ".*") + "$"
		matched, err := regexp.MatchString(pattern, a)
		if err != nil {
			slog.Error("invalid like pattern", "pattern", pattern, "error", err, "a", a, "b", b)
			panic("invalid like pattern")
		}
		return matched
	case "~", "regexp", "!~", "notregexp":
		slog.Debug("regexp", "rhs", b, "lhs", a)
		matched, err := regexp.MatchString(b, a)
		if err != nil {
			slog.Error("invalid regexp pattern", "pattern", b, "error", err, "a", a, "b", b)
			panic("invalid regexp pattern")
		}
		if op == "~" || op == "regexp" {
			return matched
		}
		return !matched
	case "in":
		v := Unwrap(Trim(b), "(", ")")
		list := Trims(Unquotes(TrimSplit(v, ",")))
		search := Unquote(a)
		slog.Debug("in", "rhs", b, "lhs", a, "list", list, "search", search)
		return slices.Contains(list, search)
	case "is":
		switch strings.ToLower(b) {
		case "null", "nil", "none", "empty":
			return a == ""
		case "not null", "not nil", "not none", "not empty":
			return a != ""
		case "true":
			return a == "true"
		case "false":
			return a == "false"
		case "not true":
			return a != "true"
		case "not false":
			return a != "false"
		default:
			panic("unknown 'is' operator: " + b)
		}
	case "not":
		panic("'not' not implemented")
	default:
		panic("unknown operator: " + op)
	}
}
