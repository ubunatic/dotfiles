package converters

import (
	"slices"
	"strings"
)

type Records [][]string

func (r Records) HeaderRow() []string {
	if len(r) == 0 {
		return nil
	}
	return r[0]
}

func (r Records) Data() Records {
	if len(r) <= 1 {
		return nil
	}
	return r[1:]
}

func (r Records) Header() Records {
	if len(r) == 0 {
		return nil
	}
	return r[:1]
}

func (r Records) Columns(name ...string) ([]Column, error) {
	return ColumnIndex(r.HeaderRow(), Cols(name...)...)
}

func (r Records) ColumnIndex(names ...string) ([]Column, error) {
	return ColumnIndex(r.HeaderRow(), Cols(names...)...)
}

func (r Records) Column(name string) (Column, error) {
	idx, err := ColumnIndex(r.HeaderRow(), Col(name))
	if err != nil {
		return zeroCol, err
	}
	if len(idx) == 0 {
		return zeroCol, ErrColumnNotFound
	}
	return idx[0], nil
}

func (r Records) Head(numRows int) Records {
	if numRows <= 0 || r.Count() == 0 {
		return r.Header() // return header or nil
	}
	// there is at least one row now
	numRows += 1 // include header
	if numRows >= len(r) {
		return r
	}
	return r[:numRows]
}

func (r Records) Tail(numRows int) Records {
	if numRows <= 0 || r.Count() == 0 {
		return r.Header() // return header or nil
	}
	// there is at least one row now
	idx := len(r) - numRows
	if idx <= 0 {
		return r
	}

	return append(r.Header(), r[idx:]...)
}

func (r Records) Count() int { return len(r.Data()) }

func (r Records) Concat(records Records) Records {
	if len(r) == 0 {
		return records
	}
	if len(records) == 0 {
		return r
	}
	return slices.Concat(r, records)
}

// Clone returns a shallow copy of the records.
func (r Records) Clone() Records {
	return slices.Clone(r)
}

// New returns new Records with the same header.
func (r Records) New() Records {
	if len(r) == 0 {
		return nil
	}
	return Records{r[0]}
}

func (r Records) Range(fn func(r Records, record []string) bool) {
	if len(r) <= 1 {
		return
	}
	for _, record := range r.Data() {
		if !fn(r, record) {
			return
		}
	}
}

func (r Records) Filter(fn func(r Records, record []string) bool) Records {
	if len(r) <= 1 {
		return r
	}
	result := Records{r[0]}
	for _, record := range r.Data() {
		if fn(r, record) {
			result = append(result, record)
		}
	}
	return result
}

func (r Records) Sort(fn func(r Records, a, b []string) int) Records {
	if len(r) <= 1 {
		return r
	}
	result := Records{r[0]}
	data := r.Data()
	slices.SortFunc(data, func(a, b []string) int { return fn(r, a, b) })
	return append(result, data...)
}

func CompareStringCol(r Records, column int, a, b []string) int {
	va := ""
	vb := ""
	if len(a) > column {
		va = a[column]
	}
	if len(b) > column {
		vb = b[column]
	}
	return strings.Compare(va, vb)
}

func CompareNumberCol(r Records, column int, fmt NumberFormat, a, b []string) int {
	va := 0.0
	vb := 0.0
	if len(a) > column {
		v, ok := CleanNumber(a[column], fmt)
		if !ok {
			panic("invalid number")
		}
		va = ToFloat(v)
	}
	if len(b) > column {
		v, ok := CleanNumber(b[column], fmt)
		if !ok {
			panic("invalid number")
		}
		vb = ToFloat(v)
	}
	if va < vb {
		return -1
	}
	if va > vb {
		return 1
	}
	return 0
}

func (r Records) SortByString(column int, asc bool) Records {
	ascNum := 1
	if !asc {
		ascNum = -1
	}
	return r.Sort(func(r Records, a, b []string) int {
		return CompareStringCol(r, column, a, b) * ascNum
	})
}

func (r Records) SortByNumber(column int, asc bool, fmt NumberFormat) Records {
	ascNum := 1
	if !asc {
		ascNum = -1
	}
	return r.Sort(func(r Records, a, b []string) int {
		return CompareNumberCol(r, column, fmt, a, b) * ascNum
	})
}
