package converters

import (
	"errors"
	"log/slog"
	"slices"
)

var ErrColumnNotFound = errors.New("column not found")

func SelectColumns(records Records, columns []string, renames map[int]string) (Records, error) {
	if len(columns) == 0 {
		return records, nil
	}

	indices, err := ColumnIndex(records[0], columns...)
	if err != nil {
		return nil, err
	}

	slog.Debug("Selecting columns", "columns", columns, "indices", indices, "renames", renames)

	return selectAndRename(records, indices, renames)
}

func selectAndRename(records Records, indices []int, renames map[int]string) (Records, error) {
	result := make(Records, len(records))

	for i, record := range records {
		newRecord := make([]string, len(indices))
		for j, idx := range indices {
			if idx >= len(record) {
				continue
			}
			newRecord[j] = record[idx]
		}
		result[i] = newRecord
	}
	return renameHeader(result, renames)
}

func renameHeader(records Records, renames map[int]string) (Records, error) {
	if len(renames) == 0 {
		return records, nil
	}
	header := make([]string, len(records[0]))
	for i := range len(header) {
		if newName, ok := renames[i]; ok {
			header[i] = newName
		} else {
			header[i] = records[0][i]
		}
	}
	return slices.Concat(Records{header}, records[1:]), nil
}
