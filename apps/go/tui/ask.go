package tui

import (
	"fmt"
	"strings"
)

func echo(msg ...any) { fmt.Println(msg...) }

func Ask(msg ...any) error {
	msg = append(msg, "? [y/N]")
	echo(msg...)
	var response string

	_, err := fmt.Scanln(&response)
	if err != nil {
		return err
	}
	response = strings.ToLower(response)
	if response == "y" || response == "yes" {
		return nil
	}
	return fmt.Errorf("aborted")
}
