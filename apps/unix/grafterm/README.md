# grafterm dashboard for rpi-exporter

Terminal Prometheus dashboard using [grafterm](https://github.com/slok/grafterm).

## Install

```bash
go install github.com/slok/grafterm/cmd/grafterm@latest
```

## Usage

Assumes Prometheus scrapes rpi-exporter at `localhost:9101` and is reachable at `localhost:9090`.

```bash
grafterm -c dashboard.yaml
```

To point at a remote Prometheus instance:

```bash
grafterm -c dashboard.yaml --datasource-url http://rpi:9090
```

## Metrics shown

- `rpi_temperature_celsius` — SoC temperature
- `rpi_clock_frequency_hertz` — ARM and core clock frequencies
- `rpi_voltage_volts` — core and SDRAM voltages
- `rpi_throttled` — throttling conditions (now)
