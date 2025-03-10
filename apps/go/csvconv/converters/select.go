package converters

import (
	"errors"
	"log/slog"
	"slices"
)

var ErrColumnNotFound = errors.New("column not found")

func SelectColumns(records Records, columns []Column) (Records, error) {
	if len(columns) == 0 {
		return records, nil
	}

	indices, err := ColumnIndex(records[0], columns...)
	if err != nil {
		return nil, err
	}

	slog.Debug("Selecting columns", "columns", columns, "indices", indices)

	return selectAndRename(records, indices)
}

func selectAndRename(records Records, columns []Column) (Records, error) {
	result := make(Records, len(records))

	for i, record := range records {
		newRecord := make([]string, len(columns))
		for j, col := range columns {
			if col.Index >= len(record) {
				continue
			}
			newRecord[j] = record[col.Index]
		}
		result[i] = newRecord
	}
	return renameHeader(result, columns)
}

func renameHeader(records Records, cols []Column) (Records, error) {
	if len(cols) == 0 {
		return records, nil
	}
	header := make([]string, len(records[0]))
	for i := range len(header) {
		rename := cols[i].Rename
		if rename != "" {
			header[i] = rename
		} else {
			header[i] = records[0][i]
		}
	}
	return slices.Concat(Records{header}, records[1:]), nil
}
