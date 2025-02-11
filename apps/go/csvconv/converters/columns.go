package converters

import (
	"fmt"
	"log/slog"
	"strconv"
)

func ColumnIndex(header []string, columns ...string) ([]int, error) {
	indices := []int{}
	notFound := []string{}

	if len(header) == 0 {
		slog.Error("Empty header")
		return nil, ErrColumnNotFound
	}

	for _, col := range columns {
		// special case for selecting all columns
		if col == "*" {
			for j := range header {
				indices = append(indices, j)
			}
			continue
		}

		if col == "" {
			slog.Error("Empty column name")
			return nil, ErrColumnNotFound
		}

		// must find the index for every selected column
		found := false
		for j, colName := range header {
			logicalIndex := fmt.Sprint(j + 1) // 1-based index
			if col == colName || col == logicalIndex {
				indices = append(indices, j)
				found = true
			}
		}
		if found {
			continue
		}

		idx, err := strconv.Atoi(col)
		if err == nil {
			if idx < 1 {
				slog.Error("Invalid column index", "index", idx)
				return nil, ErrColumnNotFound
			}
			indices = append(indices, idx-1) // append index eventhough it might be out of range
			continue
		}

		if !found {
			slog.Error("Column not found", "not_found", col, "found", indices, "select", columns)
			notFound = append(notFound, col)
		}
	}

	if len(notFound) > 0 {
		slog.Error("Columns not found", "not_found", notFound, "found", indices, "select", columns)
		return nil, ErrColumnNotFound
	}
	return indices, nil
}
