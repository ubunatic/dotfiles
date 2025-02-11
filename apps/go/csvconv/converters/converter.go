package converters

import (
	"fmt"
	"log/slog"
	"reflect"
	"runtime"
)

type Converter func(records Records) (Records, error)

func MustParse[T any](s string, fn func(string) (T, error)) T {
	v, err := fn(s)
	if err != nil {
		fnName := runtime.FuncForPC(reflect.ValueOf(fn).Pointer()).Name()
		slog.Error("parse error", "error", err, "value", s, "type", fmt.Sprintf("%T", v), "func", fnName)
		panic(err)
	}
	return v
}
