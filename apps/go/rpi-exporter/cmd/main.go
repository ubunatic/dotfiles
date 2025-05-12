package main

import (
	"flag"
	"log"
	"log/slog"
	"net/http"
	"os"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/collectors"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	rpiexporter "ubunatic.com/dotapps/go/rpi-exporter"
	"ubunatic.com/dotapps/go/rpi-exporter/collector"
)

const DefaultMetricsPort = "9101"
const MetricsRoute = "/metrics"

func main() {
	port := flag.String("port", os.Getenv("RPI_EXPORTER_PORT"), "metrics port, env:RPI_EXPORTER_PORT, default:"+DefaultMetricsPort)
	query := flag.Bool("rpi", false, "check if running on an RPi, then exit (code:0 -> is RPi)")
	install := flag.Bool("install", false, "install the binary as systemd service")
	uninstall := flag.Bool("uninstall", false, "uninstall the systemd service")

	flag.Parse()
	if *port == "" {
		*port = DefaultMetricsPort
	}

	switch {
	case *query:
		if collector.IsRpi() {
			slog.Info("running on Raspberry Pi", "code", 0)
			os.Exit(0)
		}
		slog.Info("not running on Raspberry Pi", "code", 1)
		os.Exit(1)
	case *install:
		if err := rpiexporter.Install(); err != nil {
			log.Fatalln(err)
		}
		os.Exit(0)
	case *uninstall:
		if err := rpiexporter.Uninstall(); err != nil {
			log.Fatalln(err)
		}
		os.Exit(0)
	}

	host, _ := os.Hostname()
	if host == "" {
		host = "localhost"
	}

	reg := prometheus.NewRegistry()
	c := collector.NewRPiCollector()
	reg.MustRegister(c)

	// Also expose Go and Process metrics.
	reg.MustRegister(collectors.NewGoCollector())
	reg.MustRegister(collectors.NewProcessCollector(collectors.ProcessCollectorOpts{}))

	listenAddress := ":" + *port // Default port for exporters is often in the 9xxx range
	url := "http://" + host + listenAddress + MetricsRoute
	log.Println("Starting RPi Exporter at", url)

	http.Handle(MetricsRoute, promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))

	log.Fatal(http.ListenAndServe(listenAddress, nil))
}
