package converters

import (
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestIsNumber(t *testing.T) {
	tests := []struct {
		srcSep rune
		field  string
		want   bool
	}{
		// good guys
		{'.', "1234", true},
		{'.', "123456789", true},
		{'.', "1234.56789", true},
		{'.', "1,234.56789", true},
		{'.', "123,456,789", true},
		{'.', "123,456,789.123", true},

		{',', "1234", true},
		{',', "123456789", true},
		{',', "1234,56789", true},
		{',', "1.234,56789", true},
		{',', "123.456.789", true},
		{',', "123.456.789,123", true},

		// bad guys
		{'.', "1,234,567,89", false},
		{'.', "1,234.567.89", false},
		{'.', "1.234,567,89", false},
		{'.', "1.2.1", false},
		{'.', "127.0.0.1", false},
		{'.', "abc", false},
		{'.', "", false},

		{',', "1.234.567.89", false},
		{',', "1.234,567,89", false},
		{',', "1,234.567.89", false},
		{',', "1,2,1", false},
		{',', "127,45,12", false},
		{',', "abc", false},
		{',', "", false},

		// corner cases
		{'.', "0", true},
		{'.', "0.", true},
		{'.', ".0", true},
		{'.', "0.0", true},
		{'.', ".", false},
		{'.', ",", false},
	}

	for _, tt := range tests {
		t.Run(tt.field, func(t *testing.T) {
			got := IsNumber(tt.srcSep, tt.field)
			require.Equal(t, tt.want, got)

			clean, ok := CleanNumber(tt.srcSep, tt.field)
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
				ok := IsNumber('.', val)
				require.True(t, ok, "number not clean", val)
				clean, ok := CleanNumber('.', val)
				require.True(t, ok, "number not clean", clean)
			})
		}
	}
}

func TestChangeNumberSeparators(t *testing.T) {
	tests := []struct {
		srcSep rune
		dstSep rune
		input  Records
		want   Records
	}{
		{
			srcSep: '.',
			dstSep: ',',
			input:  Records{{"1234.56", "78.90"}, {"1,234.56", "7,890.12"}},
			want:   Records{{"1234,56", "78,90"}, {"1.234,56", "7.890,12"}},
		},
		{
			srcSep: ',',
			dstSep: '.',
			input:  Records{{"1234,56", "78,90"}, {"1.234,56", "7.890,12"}},
			want:   Records{{"1234.56", "78.90"}, {"1,234.56", "7,890.12"}},
		},
		{
			srcSep: '.',
			dstSep: ',',
			input:  Records{{"1234", "5678"}, {"9.10", "11.12"}},
			want:   Records{{"1234", "5678"}, {"9,10", "11,12"}},
		},
		{
			srcSep: ',',
			dstSep: '.',
			input:  Records{{"1234", "5678"}, {"9,10", "11,12"}},
			want:   Records{{"1234", "5678"}, {"9.10", "11.12"}},
		},
		{
			srcSep: '.',
			dstSep: ',',
			input:  Records{{"not_a_number", "1234.56"}},
			want:   Records{{"not_a_number", "1234,56"}},
		},
		{
			srcSep: ',',
			dstSep: '.',
			input:  Records{{"not_a_number", "1234,56"}},
			want:   Records{{"not_a_number", "1234.56"}},
		},
	}

	for _, tt := range tests {
		t.Run(fmt.Sprintf("%c to %c", tt.srcSep, tt.dstSep), func(t *testing.T) {
			got, err := ChangeNumberSeparators(tt.srcSep, tt.dstSep, tt.input)
			require.NoError(t, err)
			require.Equal(t, tt.want, got)
		})
	}
}
