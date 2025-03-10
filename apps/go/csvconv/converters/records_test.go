package converters

import (
	"log/slog"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMain(t *testing.T) {
	slog.SetLogLoggerLevel(slog.LevelDebug)
}

func TestRecords(t *testing.T) {
	r := Records{
		{"a", "b", "c"},
		{"4.1", "5", "6"},
		{"14", "2", "3"},
	}

	header := r.Header()
	require.Equal(t, r[0], header[0])

	headerRow := r.HeaderRow()
	require.Equal(t, r[0], headerRow)

	data := r.Data()
	require.Equal(t, r[1:], data)

	columns, err := r.Columns("a", "b")
	require.NoError(t, err)
	require.Equal(t, []Column{{Name: "a", Index: 0}, {Name: "b", Index: 1}}, columns)

	head := r.Head(1)
	require.Equal(t, r[:2], head)

	tail := r.Tail(1)
	require.Equal(t, append(r[:1], r[2:]...), tail)

	count := r.Count()
	require.Equal(t, 2, count)

	sorted := r.SortByString(1, true)
	expected := Records{r.HeaderRow(), r[2], r[1]}
	require.Equal(t, expected, sorted)

	sorted = r.SortByNumber(1, true, NumberDot)
	require.Equal(t, expected, sorted)

	sorted = r.SortByNumber(1, false, NumberDot)
	expected = Records{r.HeaderRow(), r[2], r[1]}
	require.Equal(t, expected, sorted)
}

func TestHeaderOnly(t *testing.T) {
	records := Records{
		{"a", "b", "c"},
	}

	header := records.Header()
	require.Equal(t, records[0], header[0])

	headerRow := records.HeaderRow()
	require.Equal(t, records[0], headerRow)

	data := records.Data()
	require.Nil(t, data)

	columns, err := records.Columns("a", "b")
	require.NoError(t, err)
	require.Equal(t, []Column{{Name: "a", Index: 0}, {Name: "b", Index: 1}}, columns)

	head := records.Head(1)
	require.Equal(t, records, head)
	tail := records.Tail(1)
	require.Equal(t, records, tail)

	count := records.Count()
	require.Equal(t, 0, count)
}

func TestEmptyRecords(t *testing.T) {
	for _, empty := range []Records{{}, nil} {
		header := empty.Header()
		require.Nil(t, header)
		headerRow := empty.HeaderRow()
		require.Nil(t, headerRow)
		data := empty.Data()
		require.Nil(t, data)
		columns, err := empty.Columns("a", "b")
		require.Error(t, err)
		require.Nil(t, columns)
		head := empty.Head(1)
		require.Nil(t, head)
		tail := empty.Tail(1)
		require.Nil(t, tail)
		count := empty.Count()
		require.Equal(t, 0, count)
	}
}
