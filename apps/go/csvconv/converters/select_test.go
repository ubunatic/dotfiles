package converters

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSelect(t *testing.T) {
	tests := []struct {
		records Records
		columns []string
		want    Records
	}{
		{
			records: Records{{"a", "b", "c"}, {"4", "5", "6"}, {"7", "8", "9"}},
			columns: []string{"1", "b"},
			want:    Records{{"a", "b"}, {"4", "5"}, {"7", "8"}},
		},
		{
			records: Records{{"a", "b", "c"}, {"4", "5", "6"}, {"7", "8", "9"}},
			columns: []string{"1", "1"},
			want:    Records{{"a", "a"}, {"4", "4"}, {"7", "7"}},
		},
		{
			records: Records{{"a", "b", "c"}, {"4", "5", "6"}, {"7", "8", "9"}},
			columns: []string{"*", "c"},
			want:    Records{{"a", "b", "c", "c"}, {"4", "5", "6", "6"}, {"7", "8", "9", "9"}},
		},
	}

	for _, tt := range tests {
		name := fmt.Sprintf("%v", tt.columns)
		t.Run(name, func(t *testing.T) {
			got, err := SelectColumns(tt.records, tt.columns, nil)
			require.NoError(t, err)
			require.Equal(t, tt.want, got)
		})
	}
}
