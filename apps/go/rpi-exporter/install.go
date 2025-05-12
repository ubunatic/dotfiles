package rpiexporter

import (
	_ "embed"
	"fmt"
	"log/slog"
	"os"
	"os/exec"
	"path"
)

//go:embed Makefile
var makefile []byte

//go:embed service.ini
var serviceIni []byte

func newFile(dir, file string, content []byte) (*os.File, error) {
	f, err := os.Create(path.Join(dir, file))
	if err != nil {
		return nil, err
	}
	if _, err := f.Write(content); err != nil {
		return nil, err
	}
	return f, nil
}

func Uninstall() error {
	tmp, _, err := createWorkspace()
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmp)

	cmd := exec.Command("make", "-C", tmp, "host-uninstall")
	slog.Info("running command", "cmd", cmd.String())
	out, err := cmd.CombinedOutput()
	fmt.Println(string(out))
	if err != nil {
		return err
	}

	return nil
}

func Install() error {
	tmp, bin, err := createWorkspace()
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmp)

	cmd := exec.Command("make", "-C", tmp, "host-install", "srcbin="+bin)
	slog.Info("running command", "cmd", cmd.String())
	out, err := cmd.CombinedOutput()
	fmt.Println(string(out))
	if err != nil {
		return err
	}

	return nil
}

func createWorkspace() (string, string, error) {
	workspace, err := os.MkdirTemp(os.TempDir(), "rpi-exporter-install-")
	if err != nil {
		return "", "", err
	}
	slog.Info("creating temp dir", "dir", workspace)

	bin, err := os.Executable()
	if err != nil {
		return "", "", err
	}

	_, err = newFile(workspace, "Makefile", makefile)
	if err != nil {
		return "", "", err
	}

	_, err = newFile(workspace, "service.ini", serviceIni)
	if err != nil {
		return "", "", err
	}

	slog.Info("created install scripts for binary", "bin", bin, "dir", workspace)
	return workspace, bin, nil
}
