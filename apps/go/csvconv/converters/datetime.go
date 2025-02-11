package converters

import (
	"errors"
	"log/slog"
	"slices"
	"strings"
	"time"
)

type DateFormat string

const (
	DateAny    DateFormat = ""
	DateDot    DateFormat = "dd.mm.yyyy"
	DateDot2   DateFormat = "dd.mm.yy"
	DateSlash  DateFormat = "dd/mm/yyyy"
	DateSlash2 DateFormat = "dd/mm/yy"
	DateISO    DateFormat = "yyyy-mm-dd"
)

var ErrInvalidDateFormat = errors.New("invalid date format")

func MustParseDateFormat(s string) DateFormat { return MustParse(s, ParseDateFormat) }
func ParseDateFormat(s string) (DateFormat, error) {
	s = strings.TrimSpace(strings.ToLower(s))
	switch s {
	case "dd.mm.yyyy", "dot", ".":
		return DateDot, nil
	case "dd.mm.yy", "dot2":
		return DateDot2, nil
	case "dd/mm/yyyy", "slash", "/":
		return DateSlash, nil
	case "dd/mm/yy", "slash2":
		return DateSlash2, nil
	case "yyyy-mm-dd", "iso", "-":
		return DateISO, nil
	default:
		return DateAny, ErrInvalidDateFormat
	}
}

func ConvertDate(records Records, column string, from, to DateFormat) (Records, error) {
	idx, err := records.Columns(column)
	if err != nil {
		return nil, err
	}
	if len(idx) != 1 {
		return nil, ErrInvalidColumnIndex
	}

	result := Records{}
	for _, record := range records.Data() {
		if len(record) <= idx[0] {
			continue
		}
		val := record[idx[0]]
		date, err := ParseDate(val, from)
		if err != nil {
			return nil, err
		}
		newRecord := slices.Clone(record)
		newRecord[idx[0]] = FormatDate(date, to)
		result = append(result, newRecord)
	}

	return records.Header().Concat(result), nil
}

func ConvertDates(records Records, from, to DateFormat) (Records, error) {
	result := Records{}
	for _, record := range records {
		newRecord := make([]string, len(record))
		for j, field := range record {
			slog.Debug("converting date", "date", field, "from", from, "to", to)
			if date, err := ParseDate(field, from); err == nil {
				newRecord[j] = FormatDate(date, to)
			} else {
				newRecord[j] = field
			}
		}
		result = append(result, newRecord)
	}
	return result, nil
}

func ParseDate(s string, format DateFormat) (time.Time, error) {
	switch format {
	case DateAny:
		for _, f := range []DateFormat{DateDot, DateSlash, DateISO, DateDot2, DateSlash2} {
			if t, err := ParseDate(s, f); err == nil {
				return t, nil
			}
		}
		return time.Time{}, ErrInvalidDateFormat
	case DateDot:
		return time.Parse("02.01.2006", s)
	case DateDot2:
		return time.Parse("02.01.06", s)
	case DateSlash:
		return time.Parse("02/01/2006", s)
	case DateSlash2:
		return time.Parse("02/01/06", s)
	case DateISO:
		return time.Parse("2006-01-02", s)
	default:
		return time.Time{}, ErrInvalidDateFormat
	}
}

func FormatDate(d time.Time, format DateFormat) string {
	switch format {
	case DateDot:
		return d.Format("02.01.2006")
	case DateDot2:
		return d.Format("02.01.06")
	case DateSlash:
		return d.Format("02/01/2006")
	case DateSlash2:
		return d.Format("02/01/06")
	case DateISO:
		return d.Format("2006-01-02")
	default:
		return d.Format("2006-01-02")
	}
}
