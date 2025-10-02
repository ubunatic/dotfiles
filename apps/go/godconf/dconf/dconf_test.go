package dconf_test

import (
	"slices"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	"ubunatic.com/dotapps/go/godconf/dconf"
)

// dconf read /org/gnome/Disks/image-dir-uri
var testValues = []string{
	`"single: '"`,
	`"escaped double \""`,
	`'single item'`,
	`"double item"`,
}

func testValueCombinations() [][]string {
	var singles [][]string
	var pairs [][]string
	var triples [][]string

	// single items
	for i, v := range testValues {
		singles = append(singles, []string{v})
		// pairs
		for j := i; j < len(testValues); j++ {
			pairs = append(pairs, []string{v, testValues[j]})
			// triples
			for k := j; k < len(testValues); k++ {
				triples = append(triples, []string{v, testValues[j], testValues[k]})
			}
		}
	}
	return slices.Concat(singles, pairs, triples)
}

func unquoteAndUnescape(values []string) []string {
	res := make([]string, len(values))
	for i, v := range values {
		if strings.HasPrefix(v, `"`) || strings.HasPrefix(v, `'`) {
			res[i] = v[1 : len(v)-1]
		}
		res[i] = strings.ReplaceAll(res[i], `\"`, `"`)
	}
	return res
}

func TestParseDConfArray(t *testing.T) {
	type test struct {
		name string // description of this test case
		// Named input parameters for target function.
		v    string
		want []string
	}

	tests := []test{
		{name: "empty string", v: "", want: nil},
		{name: "empty array", v: "[]", want: nil},
		{name: "array with spaces", v: "[   ]", want: nil},
	}

	for _, sep := range []string{",", ", ", " , "} {
		for _, items := range testValueCombinations() {
			v := "[" + strings.Join(items, sep) + "]"
			tests = append(tests, test{
				name: "array with items: " + v,
				v:    v,
				want: unquoteAndUnescape(items),
			})
		}
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := dconf.ParseArray(tt.v)
			require.NoError(t, err)
			require.EqualValues(t, tt.want, got)
		})
		if t.Failed() {
			break
		}
	}
}
