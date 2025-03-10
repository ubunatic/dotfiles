package converters

import (
	"log/slog"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestFilter(t *testing.T) {
	slog.SetLogLoggerLevel(slog.LevelDebug)
	tests := []struct {
		records Records
		queries []string // test multiple logically equivalent queries in on run to make the tests less verbose
		want    Records
		wantErr bool
	}{
		{
			records: Records{
				[]string{"name", "age"},
				[]string{"Alice", "25"},
				[]string{"Bob", "30"},
			},
			queries: []string{"name == Alice", "age == 25", "age < 30"},
			want: Records{
				[]string{"name", "age"},
				[]string{"Alice", "25"},
			},
			wantErr: false,
		},
		{
			records: Records{
				[]string{"name", "age"},
				[]string{"Alice", "25"},
				[]string{"Bob", "30"},
			},
			queries: []string{"name = Bob", "age = 30", "age >= 26", "age >= 30"},
			want: Records{
				[]string{"name", "age"},
				[]string{"Bob", "30"},
			},
			wantErr: false,
		},
		{
			records: Records{
				[]string{"name", "age"},
				[]string{"Alice A.", "25"},
				[]string{"Bob B.", "30"},
				[]string{"Charlie C.", "35"},
			},
			queries: []string{"age in (25, 30)", "name in ('Alice A.', 'Bob B.')"},
			want: Records{
				[]string{"name", "age"},
				[]string{"Alice A.", "25"},
				[]string{"Bob B.", "30"},
			},
		},
		{
			records: Records{
				[]string{"name", "age"},
				[]string{"Alice A.", "25"},
				[]string{"Bob B.", "30"},
				[]string{"Charlie C.", ""},
			},
			queries: []string{"age is empty", "age is null", "age == ''"},
			want: Records{
				[]string{"name", "age"},
				[]string{"Charlie C.", ""},
			},
		},
		{
			records: Records{
				[]string{"name", "active"},
				[]string{"Alice A.", "true"},
				[]string{"Bob B.", "false"},
			},
			queries: []string{"active is true", "active is not false"},
			want: Records{
				[]string{"name", "active"},
				[]string{"Alice A.", "true"},
			},
		},
		{},

		// Add more test cases as needed
	}

	for _, tt := range tests {
		for _, query := range tt.queries {
			name := strings.ReplaceAll(query, " ", "")
			t.Run(name, func(t *testing.T) {
				parts := strings.Split(query, " ")
				rest := strings.Join(parts[2:], " ")
				got, err := Filter(tt.records, parts[0], parts[1], rest)
				require.Equal(t, tt.wantErr, err != nil)
				require.Equal(t, tt.want, got)
			})
		}
	}
}

// func equalRecords(a, b Records) bool {
// 	if len(a) != len(b) {
// 		return false
// 	}
// 	for i := range a {
// 		for k, v := range a[i] {
// 			if b[i][k] != v {
// 				return false
// 			}
// 		}
// 	}
// 	return true
// }
