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
		case "sort", "order":
			stmt = NewSortStatement(tup.args, tup.options...)
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
	words := strings.Split(text, " ")
	keyword := strings.ToLower(words[0])   // example: "select", "number:float"
	kwParts := strings.Split(keyword, ":") // example: ["select"], ["number", "float"]
	tuple := statementTuple{
		keyword: kwParts[0],
	}
	if len(kwParts) > 1 { // keyword has options
		tuple.options = kwParts[1:]
	}
	if len(words) > 1 { // statement has multiple args
		tuple.args = words[1:]
	}
	return tuple
}
