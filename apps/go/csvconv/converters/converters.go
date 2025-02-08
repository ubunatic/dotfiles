package converters

type Converter func(records Records) (Records, error)

type Records [][]string

func CutHeadersConverter(n int64) Converter {
	return func(records Records) (Records, error) {
		return CutHeaders(records, n)
	}
}

func CutHeaders(records Records, n int64) (Records, error) {
	if n <= 0 {
		return records, nil
	}

	if n >= int64(len(records)) {
		return nil, nil
	}

	return records[n:], nil
}
