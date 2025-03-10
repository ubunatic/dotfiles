package converters

import (
	"fmt"
	"log/slog"
	"strconv"
)

type Column struct {
	Name   string
	Rename string
	Type   string
	Cast   string
	Index  int
}

var zeroCol Column

func Col(name string) Column {
	return Column{Name: name}
}

func Cols(names ...string) []Column {
	columns := make([]Column, len(names))
	for i, name := range names {
		columns[i] = Column{
			Name:  name,
			Index: i,
		}
	}
	return columns
}

func ColNames(cols []Column) []string {
	names := make([]string, len(cols))
	for i := range cols {
		names[i] = cols[i].Name
	}
	return names
}

func ColumnIndex(header []string, columns ...Column) ([]Column, error) {
	indices := []Column{}
	notFound := []string{}

	if len(header) == 0 {
		slog.Error("Empty header")
		return nil, ErrColumnNotFound
	}

	for _, col := range columns {
		// special case for selecting all columns
		if col.Name == "*" {
			indices = append(indices, Cols(header...)...)
			continue
		}

		if col.Name == "" {
			slog.Error("Empty column name")
			return nil, ErrColumnNotFound
		}

		// find the index for every selected column name
		found := false
		for j, colName := range header {
			logicalIndex := fmt.Sprint(j + 1) // 1-based index
			if col.Name == colName || col.Name == logicalIndex {
				col.Index = j
				col.Name = colName
				indices = append(indices, col)
				found = true
			}
		}
		if found {
			continue
		}

		// allow over-indexing, when header row is shorter than data rows
		idx, err := strconv.Atoi(col.Name)
		if err == nil {
			if idx < 1 {
				slog.Error("Invalid column index", "index", idx)
				return nil, ErrColumnNotFound
			}
			col.Index = idx - 1
			indices = append(indices, col) // append index eventhough it might be out of range
			continue
		}

		if !found {
			slog.Error("Column not found", "not_found", col, "found", indices, "select", columns)
			notFound = append(notFound, col.Name)
		}
	}

	if len(notFound) > 0 {
		slog.Error("Columns not found", "not_found", notFound, "found", indices, "select", columns)
		return nil, ErrColumnNotFound
	}
	return indices, nil
}
