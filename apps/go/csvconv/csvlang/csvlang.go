package csvlang

import (
	"log/slog"
	"strings"

	"ubunatic.com/dotapps/go/csvconv/converters"
)

// CsvLang Grammar
// ===============
// The CSV transformation language is a simple language for defining
// data transformation for CSV file content.
//
// The language uses sequences of statements separated by a pipe "|".
// Each statement is a transformation that can be applied to the CSV data.
//
// The following column-selection statements are supported:
// - `select <column1>, <column2>, ...`: selects the column with the given name.
// - `select <old> as <new>`: renames the column with the given old name to the new name.
// - `number[:<from>:<to>] <column>`: converts the numerical values of the column to the given type.
// - `date[:<from>:<to>] <column>`: converts the date values of the column to the given type.
//
// The following full-line statements are supported:
// - `numbers <from>:<to>`: converts all the numerical values of the CSV file to the given type.
// - `dates <from>:<to>`: converts all the date values of the CSV file to the given type.
// - `if <column> <op> <value>`: filters the rows of the CSV file based on the given condition.
// - `and <column> <op> <value>`: filters the rows of the CSV file based on the given condition.
//
// The following operators are supported:
// - common comparison operators: `=`, `!=`, `>`, `<`, `>=`, `<=`.
// - common match operators: `~`, `!~`, `in`, `is`, `is not`, `like`
//
// Example:
// ```
// select name, age | number:float age | if age > 18 | if name ~ '[a-z]+' | numbers comma:dot | dates iso
// ```

type Statement interface {
	// Converter returns the converter that corresponds to the statement.
	Converter() converters.Converter
}

func Col(name string) converters.Column        { return converters.Col(name) }
func Cols(names ...string) []converters.Column { return converters.Cols(names...) }

type SelectStatement struct {
	Columns []converters.Column
}

func (s *SelectStatement) ColumnNames() []string {
	names := make([]string, len(s.Columns))
	for i, col := range s.Columns {
		names[i] = col.Name
	}
	return names
}

func (s *SelectStatement) Renames() []string {
	renames := make([]string, len(s.Columns))
	for i, col := range s.Columns {
		renames[i] = col.Rename
	}
	return renames
}

type NumberStatement struct {
	Column string
	From   converters.NumberFormat
	To     converters.NumberFormat
}

type NumbersStatement struct {
	From converters.NumberFormat
	To   converters.NumberFormat
}

type DateStatement struct {
	Column string
	From   converters.DateFormat
	To     converters.DateFormat
}

type DatesStatement struct {
	From converters.DateFormat
	To   converters.DateFormat
}

type FilterStatement struct {
	Column converters.Column
	Op     string
	Value  string
}

type SortStatement struct {
	Column       string
	Asc          bool
	AsNumber     bool
	NumberFormat converters.NumberFormat
}

func NewSelectStatement(args ...string) *SelectStatement {
	cols := []converters.Column{}

	arg := strings.Join(args, " ")
	args = converters.TrimSplit(arg, ",")

	for idx, arg := range args {
		renameParts := converters.Unquotes(converters.TrimSplit(arg, "as", "->"))
		col := renameParts[0]

		colParts := strings.Split(col, ":")
		colType := ""
		colCast := ""
		switch len(colParts) {
		case 1: // pass
		case 2:
			colCast = colParts[1]
		case 3:
			colType = colParts[1]
			colCast = colParts[2]
		default:
			panic("invalid cast in select statement")
		}

		rename := ""
		switch len(renameParts) {
		case 1: // pass
		case 2:
			rename = renameParts[1]
		default:
			panic("invalid rename in select statement")
		}

		cols = append(cols, converters.Column{
			Name:   col,
			Index:  idx,
			Rename: rename,
			Type:   colType,
			Cast:   colCast,
		})
	}

	return &SelectStatement{Columns: cols}
}

func getNumberFormat(opts []string) (from, to converters.NumberFormat) {
	switch len(opts) {
	case 0:
		return converters.NumberDot, converters.NumberDot
	case 1:
		return converters.NumberDot, converters.MustParseNumberFormat(opts[0])
	case 2:
		return converters.MustParseNumberFormat(opts[0]), converters.MustParseNumberFormat(opts[1])
	default:
		slog.Error("invalid number options", "opts", opts)
		panic("invalid number options")
	}
}

func NewNumberStatement(args []string, opts ...string) *NumberStatement {
	if len(args) != 1 {
		panic("invalid number statement")
	}
	s := &NumberStatement{
		Column: converters.Trim(args[0]),
	}
	s.From, s.To = getNumberFormat(opts)
	return s
}

func NewNumbersStatement(args ...string) *NumbersStatement {
	opts := converters.TrimSplit(strings.Join(args, ":"), ":") // convert args to options
	s := &NumbersStatement{}
	s.From, s.To = getNumberFormat(opts)
	return s
}

func getDateFormats(opts []string) (from, to converters.DateFormat) {
	switch len(opts) {
	case 0:
		return converters.DateAny, converters.DateISO
	case 1:
		return converters.DateAny, converters.MustParseDateFormat(opts[0])
	case 2:
		return converters.MustParseDateFormat(opts[0]), converters.MustParseDateFormat(opts[1])
	default:
		slog.Error("invalid date options", "opts", opts)
		panic("invalid date options")
	}
}

func NewDateStatement(args []string, opts ...string) *DateStatement {
	if len(args) != 1 {
		panic("invalid date statement")
	}
	s := &DateStatement{
		Column: converters.Trim(args[0]),
	}
	s.From, s.To = getDateFormats(opts)
	return s
}

func NewDatesStatement(args ...string) *DatesStatement {
	s := &DatesStatement{}
	opts := converters.TrimSplit(strings.Join(args, ":"), ":") // convert args to options
	s.From, s.To = getDateFormats(opts)
	return s
}

func NewFilterStatement(args []string) *FilterStatement {
	if len(args) < 3 {
		panic("invalid filter statement")
	}
	// TODO: add OR support
	return &FilterStatement{
		Column: converters.Col(converters.Trim(args[0])),
		Op:     strings.ToLower(converters.Trim(args[1])),
		Value:  converters.Trim(strings.Join(args[2:], " ")),
	}
}

func NewSortStatement(args []string, opts ...string) *SortStatement {
	asc := true
	number := false
	fmt := converters.NumberInvalid

	for _, opt := range opts {
		switch opt {
		case "asc":
			asc = true
		case "desc":
			asc = false
		case "num":
			if fmt == converters.NumberInvalid {
				fmt = converters.NumberDot
			}
		case "dot":
			fmt = converters.NumberDot
		case "comma":
			fmt = converters.NumberComma
		default:
			slog.Error("invalid sort option", "opt", opt)
		}
	}

	return &SortStatement{
		Column:   converters.Trim(args[0]),
		Asc:      asc,
		AsNumber: number,
	}
}

// Implement the Statement interface for each statement type.
// This allows to use the statements in the CSV transformation pipeline.

func (s *SelectStatement) Converter() converters.Converter {
	fn := func(records converters.Records) (converters.Records, error) {
		return converters.SelectColumns(records, s.Columns)
	}
	return fn
}

func (s *NumberStatement) Converter() converters.Converter {
	fn := func(records converters.Records) (converters.Records, error) {
		return converters.ConvertNumber(records, s.Column, s.From, s.To)
	}
	return fn
}

func (s *NumbersStatement) Converter() converters.Converter {
	fn := func(records converters.Records) (converters.Records, error) {
		return converters.ConvertNumbers(records, s.From, s.To)
	}
	return fn
}

func (s *DateStatement) Converter() converters.Converter {
	fn := func(records converters.Records) (converters.Records, error) {
		return converters.ConvertDate(records, s.Column, s.From, s.To)
	}
	return fn
}

func (s *DatesStatement) Converter() converters.Converter {
	fn := func(records converters.Records) (converters.Records, error) {
		return converters.ConvertDates(records, s.From, s.To)
	}
	return fn
}

func (s *FilterStatement) Converter() converters.Converter {
	fn := func(records converters.Records) (converters.Records, error) {
		return converters.Filter(records, s.Column.Name, s.Op, s.Value)
	}
	return fn
}

func (s *SortStatement) Converter() converters.Converter {
	fn := func(records converters.Records) (converters.Records, error) {
		return converters.Sort(records, s.Column, s.Asc, s.NumberFormat)
	}
	return fn
}
