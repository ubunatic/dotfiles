package converters

func Sort(records Records, column string, asc bool, fmt NumberFormat) (Records, error) {
	i, err := records.Column(column)
	if err != nil {
		return nil, err
	}
	if fmt == NumberInvalid {
		return records.SortByString(i, asc), nil
	}
	return records.SortByNumber(i, asc, fmt), nil
}
