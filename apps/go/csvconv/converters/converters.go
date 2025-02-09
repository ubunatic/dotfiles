package converters

import (
	"fmt"
	"log/slog"
	"reflect"
	"runtime"
)

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

func MustParse[T any](s string, fn func(string) (T, error)) T {
	v, err := fn(s)
	if err != nil {
		fnName := runtime.FuncForPC(reflect.ValueOf(fn).Pointer()).Name()
		slog.Error("parse error", "error", err, "value", s, "type", fmt.Sprintf("%T", v), "func", fnName)
		panic(err)
	}
	return v
}
