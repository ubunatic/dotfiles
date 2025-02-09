package converters

import (
	"fmt"
	"log/slog"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestIsNumber(t *testing.T) {
	tests := []struct {
		srcFmt NumberFormat
		field  string
		want   bool
	}{
		// good guys
		{NumberDot, "1234", true},
		{NumberDot, "123456789", true},
		{NumberDot, "1234.56789", true},
		{NumberDot, "1,234.56789", true},
		{NumberDot, "123,456,789", true},
		{NumberDot, "123,456,789.123", true},

		{NumberComma, "1234", true},
		{NumberComma, "123456789", true},
		{NumberComma, "1234,56789", true},
		{NumberComma, "1.234,56789", true},
		{NumberComma, "123.456.789", true},
		{NumberComma, "123.456.789,123", true},

		// bad guys
		{NumberDot, "1,234,567,89", false},
		{NumberDot, "1,234.567.89", false},
		{NumberDot, "1.234,567,89", false},
		{NumberDot, "1.2.1", false},
		{NumberDot, "127.0.0.1", false},
		{NumberDot, "abc", false},
		{NumberDot, "", false},

		{NumberComma, "1.234.567.89", false},
		{NumberComma, "1.234,567,89", false},
		{NumberComma, "1,234.567.89", false},
		{NumberComma, "1,2,1", false},
		{NumberComma, "127,45,12", false},
		{NumberComma, "abc", false},
		{NumberComma, "", false},

		// corner cases
		{NumberDot, "0", true},
		{NumberDot, "0.", true},
		{NumberDot, ".0", true},
		{NumberDot, "0.0", true},
		{NumberDot, ".", false},
		{NumberDot, ",", false},
	}

	for _, tt := range tests {
		t.Run(tt.field, func(t *testing.T) {
			got := IsNumber(tt.field, tt.srcFmt)
			require.Equal(t, tt.want, got)

			clean, ok := CleanNumber(tt.field, tt.srcFmt)
			require.Equal(t, tt.want, ok, "number not clean", clean)
		})
	}
}

func TestRandomNumbers(t *testing.T) {
	floats := []float64{
		0, +0, -0, -1, 1, -1,
	}
	for i := 0; i < 10; i++ {
		a := time.Now().UnixNano()%100000 + 1
		b := time.Now().UnixNano()%1000000 + 1
		floats = append(floats, float64(a)/float64(b))
		floats = append(floats, float64(a)*float64(b))
		floats = append(floats, float64(a), float64(b))
	}

	for _, f := range floats {
		floatVal := fmt.Sprintf("%f", f)
		intVal := fmt.Sprint(int(f))
		for _, val := range []string{floatVal, intVal} {
			t.Run(val, func(t *testing.T) {
				ok := IsNumber(val, NumberDot)
				require.True(t, ok, "number not clean", val)
				clean, ok := CleanNumber(val, NumberDot)
				require.True(t, ok, "number not clean", clean)
			})
		}
	}
}

func TestChangeNumberSeparators(t *testing.T) {
	ab := []string{"a", "b"}
	tests := []struct {
		srcFmt  NumberFormat
		dstFmt  NumberFormat
		input   Records
		want    Records
		wantErr bool
	}{
		{
			srcFmt: NumberDot,
			dstFmt: NumberComma,
			input:  Records{ab, {"1234.56", "78.90"}, {"1,234.56", "7,890.12"}},
			want:   Records{ab, {"1234,56", "78,90"}, {"1.234,56", "7.890,12"}},
		},
		{
			srcFmt: NumberComma,
			dstFmt: NumberDot,
			input:  Records{ab, {"1234,56", "78,90"}, {"1.234,56", "7.890,12"}},
			want:   Records{ab, {"1234.56", "78.90"}, {"1,234.56", "7,890.12"}},
		},
		{
			srcFmt: NumberDot,
			dstFmt: NumberComma,
			input:  Records{ab, {"1234", "5678"}, {"9.10", "11.12"}},
			want:   Records{ab, {"1234", "5678"}, {"9,10", "11,12"}},
		},
		{
			srcFmt: NumberComma,
			dstFmt: NumberDot,
			input:  Records{ab, {"1234", "5678"}, {"9,10", "11,12"}},
			want:   Records{ab, {"1234", "5678"}, {"9.10", "11.12"}},
		},
		{
			srcFmt:  NumberDot,
			dstFmt:  NumberComma,
			input:   Records{ab, {"not_a_number", "1234.56"}},
			want:    Records{ab, {"not_a_number", "1234,56"}},
			wantErr: true,
		},
		{
			srcFmt:  NumberComma,
			dstFmt:  NumberDot,
			input:   Records{ab, {"not_a_number", "1234,56"}},
			want:    Records{ab, {"not_a_number", "1234.56"}},
			wantErr: true,
		},
	}

	slog.SetLogLoggerLevel(slog.LevelDebug)

	for _, tt := range tests {
		t.Run(fmt.Sprintf("%v to %v", tt.srcFmt, tt.dstFmt), func(t *testing.T) {
			got, err := ConvertNumbers(tt.input, tt.srcFmt, tt.dstFmt)
			require.NoError(t, err)
			require.Equal(t, tt.want, got)

			got, err = ConvertNumber(tt.input, "a", tt.srcFmt, tt.dstFmt)
			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)

			got, err = ConvertNumber(got, "b", tt.srcFmt, tt.dstFmt)
			require.NoError(t, err)
			require.Equal(t, tt.want, got)

			got, err = ConvertNumbers(tt.input, tt.srcFmt, tt.dstFmt)
			require.NoError(t, err)
			require.Equal(t, tt.want, got)
		})
	}
}
