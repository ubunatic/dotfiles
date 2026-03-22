# grafterm dashboards

Terminal Prometheus dashboard using [grafterm](https://github.com/slok/grafterm).

## Install

```bash
go install github.com/slok/grafterm/cmd/grafterm@latest
```

## Dashboards

### Raspberry Pi (`dashboard.json`)

Assumes Prometheus scrapes rpi-exporter at `localhost:9101`.

```bash
grafterm -c dashboard.json
```

Metrics: `rpi_temperature_celsius`, `rpi_clock_frequency_hertz`, `rpi_voltage_volts`, `rpi_throttled`

### M4 Mac (`m4-dashboard.json`)

Requires macmon exporter running on `localhost:9102`. Start it with:

```bash
make macmon-exporter   # in the fv repo
```

```bash
grafterm -c m4-dashboard.json
```

Metrics: E-core/P-core/GPU usage %, CPU/GPU/ANE/system power (W), CPU/GPU temperature (°C), RAM/swap used
