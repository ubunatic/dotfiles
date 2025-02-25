package csvlang

import (
	"log/slog"
	"testing"

	"github.com/stretchr/testify/require"
	"ubunatic.com/dotapps/go/csvconv/converters"
)

func TestMain(t *testing.T) {
	slog.SetLogLoggerLevel(slog.LevelDebug)
}

func TestParse(t *testing.T) {
	tests := []struct {
		program string
		expect  Statement
		expects []Statement
	}{
		{
			program: "select col1, col2",
			expect:  &SelectStatement{Columns: []string{"col1", "col2"}},
		},
		{
			program: "number:dot col1",
			expect:  &NumberStatement{Column: "col1", From: converters.NumberDot, To: converters.NumberDot},
		},
		{
			program: "date:iso col1",
			expect:  &DateStatement{Column: "col1", From: converters.DateAny, To: converters.DateISO},
		},
		{
			program: "numbers",
			expect:  &NumbersStatement{From: converters.NumberDot, To: converters.NumberDot},
		},
		{
			program: "dates",
			expect:  &DatesStatement{From: converters.DateAny, To: converters.DateISO},
		},
		{
			program: "filter col1 > 10",
			expect:  &FilterStatement{Column: "col1", Op: ">", Value: "10"},
		},
		{
			program: "and col1 = 10",
			expect:  &FilterStatement{Column: "col1", Op: "=", Value: "10"},
		},
		{
			program: "select col1|numbers dot|dates iso",
			expects: []Statement{
				&SelectStatement{Columns: []string{"col1"}},
				&NumbersStatement{From: converters.NumberDot, To: converters.NumberDot},
				&DatesStatement{From: converters.DateAny, To: converters.DateISO},
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.program, func(t *testing.T) {
			got := Parse(tt.program)
			var got1 Statement
			if len(got) > 0 {
				got1 = got[0]
			}
			switch {
			case tt.expect != nil:
				require.NotNil(t, got1)
				require.Equal(t, tt.expect, got1)
			case tt.expects != nil:
				require.Equal(t, tt.expects, got)
			default:
				require.Nil(t, got)
			}
		})
	}
}

func TestPrograms(t *testing.T) {
	slog.SetLogLoggerLevel(slog.LevelDebug)
	data := converters.Records{
		{"name", "age", "active", "full name", "date"},
		{"Alice", "25", "true", "Alice A.", "01.01.2020"},
		{"Bob", "30", "false", "Bob B.", "03.03.2023"},
		{"Charlie", "", "", "Charlie C.", "12.12.2021"},
	}

	tests := []struct {
		program string
		want    converters.Records
		wantErr bool
	}{
		{
			program: "select name, age | filter name ~ '[a-z]*'",
			want: converters.Records{
				{"name", "age"},
				{"Alice", "25"},
				{"Bob", "30"},
				{"Charlie", ""},
			},
		},
		{
			program: "select * | filter age = 30 | select name | filter name = 'Bob' | filter name like 'B%'",
			want: converters.Records{
				{"name"},
				{"Bob"},
			},
		},
		{
			program: "select 'full name' as name2 | select name2::name | filter name ~ 'Bob'",
			want: converters.Records{
				{"name"},
				{"Bob B."},
			},
		},
		{
			program: "select name, date | dates iso | date:iso:slash date | date:slash:dot date | date:iso date | filter name = 'Bob'",
			want: converters.Records{
				{"name", "date"},
				{"Bob", "2023-03-03"},
			},
		},
		{
			program: "select name, age | number:dot age | sort:num age | select name",
			want: converters.Records{
				{"name"}, {"Charlie"}, {"Alice"}, {"Bob"},
			},
		},
		{
			program: "select name, age | number:dot age | sort:num:desc age | select name",
			want: converters.Records{
				{"name"}, {"Bob"}, {"Alice"}, {"Charlie"},
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.program, func(t *testing.T) {
			prg := Parse(tt.program)
			require.NotNil(t, prg)
			got := data
			var err error
			for _, s := range prg {
				slog.Debug("Statement", "statement", s, "data", got)
				got, err = s.Converter()(got)
				if err != nil {
					break
				}
			}
			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			require.Equal(t, tt.want, got)
		})
	}
}
