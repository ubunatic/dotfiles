package converters

func Sort(records Records, column string, asc bool, fmt NumberFormat) (Records, error) {
	col, err := records.Column(column)
	if err != nil {
		return nil, err
	}
	if fmt == NumberInvalid {
		return records.SortByString(col.Index, asc), nil
	}
	return records.SortByNumber(col.Index, asc, fmt), nil
}
