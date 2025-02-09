package csvlang

import (
	"log/slog"
	"strings"

	"ubunatic.com/dotapps/go/csvconv/converters"
)

// Parse parses the CSV transformation language into a sequence of [converters.Converter].
func Parse(program ...string) []Statement {
	statements := []Statement{}
	for _, tup := range parseStatements(program...) {
		var stmt Statement
		switch tup.keyword {
		case "select", "sel", "get":
			stmt = NewSelectStatement(tup.args...)
		case "number", "num":
			stmt = NewNumberStatement(tup.args, tup.options...)
		case "date":
			stmt = NewDateStatement(tup.args, tup.options...)
		case "numbers", "nums":
			stmt = NewNumbersStatement(tup.args...)
		case "dates":
			stmt = NewDatesStatement(tup.args...)
		case "filter", "and", "where", "if":
			stmt = NewFilterStatement(tup.args)
		default:
			panic("unknown statement: " + tup.keyword)
		}
		statements = append(statements, stmt)
	}
	return statements
}

type statementTuple struct {
	keyword string
	options []string
	args    []string
}

// parseStatements parses a Csvlang program into a sequence of statement texts.
func parseStatements(program ...string) []statementTuple {
	prg := strings.Join(program, " ")
	statements := []statementTuple{}
	for _, line := range converters.TrimSplit(prg, "|") {
		tuple := parseTuple(line)
		slog.Debug("parsed statement", "tuple", tuple, "len", len(tuple.args))
		statements = append(statements, tuple)
	}
	return statements
}

// parseTuple parses a statement text into a statement tuple.
func parseTuple(text string) statementTuple {
	tuple := statementTuple{}
	parts := strings.Split(text, " ")
	kw := strings.ToLower(parts[0])
	kwParts := strings.Split(kw, ":")
	tuple.keyword = kwParts[0]
	if len(kwParts) > 1 {
		tuple.options = kwParts[1:]
	}
	if len(parts) > 1 {
		tuple.args = parts[1:]
	}
	return tuple
}
