package gsu

import (
	"errors"
)

var ErrConnectFailed = errors.New("connect failed")
var ErrLsFailed = errors.New("ls failed")
var ErrRmFailed = errors.New("rm failed")
var ErrBadArguments = errors.New("bad arguments")
var ErrRmAborted = errors.New("rm aborted")
var ErrNotFound = errors.New("object not found")
