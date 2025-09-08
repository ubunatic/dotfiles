package vscode

import (
	"fmt"
	"slices"
)

type mergeInfo struct {
	Duplicates KeyBindings
}

type MergeResult struct {
	Contents []byte
	mergeInfo
}

func MergedKeybindings(file1, file2 string) (MergeResult, error) {
	if file1 == "" || file2 == "" {
		return MergeResult{}, fmt.Errorf("both file paths must be provided")
	}
	b1, err := ReadKeybindings(file1)
	if err != nil {
		return MergeResult{}, fmt.Errorf("failed to read keybindings from %s: %w", file1, err)
	}
	b2, err := ReadKeybindings(file2)
	if err != nil {
		return MergeResult{}, fmt.Errorf("failed to read keybindings from %s: %w", file2, err)
	}
	// Compare the keybindings in the two files
	result, info := MergeBindings(b1, b2)

	contents, err := result.MarshalJSONCIndent("", "   ")
	if err != nil {
		return MergeResult{}, fmt.Errorf("failed to marshal merged keybindings: %w", err)
	}

	return MergeResult{Contents: contents, mergeInfo: info}, nil
}

func MergeBindings(existing, more *BindingFile) (*BindingFile, mergeInfo) {
	return mergeKeybindings(existing, more)
}

func mergeKeybindings(existing, more *BindingFile) (*BindingFile, mergeInfo) {
	new := make(KeyBindings, 0, len(existing.KeyBindings)+len(more.KeyBindings))
	duplicates := KeyBindings{}
	for _, kb := range []*BindingFile{existing, more} {
		for _, binding := range kb.KeyBindings {
			if new.Contains(binding.Key, binding.When) {
				duplicates = append(duplicates, binding.WithComment(kb.file.Name()))
				continue
			}
			new = append(new, binding)
		}
	}

	b := &BindingFile{
		Comments:    existing.Comments,
		KeyBindings: new,
	}
	switch {
	case len(existing.Comments) == 0:
		// use more as is
		b.Comments = more.Comments
	case len(more.Comments) == 0:
		// keep existing
	default:
		// add more
		for _, c := range more.Comments {
			if slices.Contains(existing.Comments, c) {
				continue
			}
			b.Comments = append(b.Comments, fmt.Sprintf("source:%s", c))
		}
	}

	return b, mergeInfo{Duplicates: duplicates}
}
