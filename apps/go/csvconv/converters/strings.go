package converters

import (
	"strings"
)

func Split(value string, sep ...string) []string {
	if len(value) == 0 {
		return nil
	}
	if len(sep) == 0 {
		return strings.Fields(value)
	}
	result := []string{value}

	// split by all separators, recursively
	for _, s := range sep {
		parts := []string{}
		for _, part := range result {
			parts = append(parts, strings.Split(part, s)...)
		}
		result = parts
	}
	return result
}

func Splits(list []string, sep ...string) [][]string {
	result := make([][]string, len(list))
	for i, s := range list {
		result[i] = Split(s, sep...)
	}
	return result
}

func Trim(s string) string {
	return strings.TrimSpace(s)
}

func Trims(list []string) []string {
	result := make([]string, len(list))
	for i, s := range list {
		result[i] = strings.TrimSpace(s)
	}
	return result
}

func TrimSplit(s string, sep ...string) []string {
	return Trims(Split(Trim(s), sep...))
}

func TrimSplits(list []string, sep ...string) [][]string {
	result := make([][]string, len(list))
	for i, s := range list {
		result[i] = TrimSplit(s, sep...)
	}
	return result
}

func Unquote(s string) string {
	if len(s) < 2 {
		return s
	}
	if s[0] == '"' && s[len(s)-1] == '"' {
		return s[1 : len(s)-1]
	}
	if s[0] == '\'' && s[len(s)-1] == '\'' {
		return s[1 : len(s)-1]
	}
	return s
}

func Unquotes(list []string) []string {
	result := make([]string, len(list))
	for i, s := range list {
		result[i] = Unquote(s)
	}
	return result
}

func Unwrap(s, prefix, suffix string) string {
	if strings.HasPrefix(s, prefix) && strings.HasSuffix(s, suffix) {
		return s[len(prefix) : len(s)-len(suffix)]
	}
	return s
}

func Unwraps(list []string, prefix, suffix string) []string {
	result := make([]string, len(list))
	for i, s := range list {
		result[i] = Unwrap(s, prefix, suffix)
	}
	return result
}
