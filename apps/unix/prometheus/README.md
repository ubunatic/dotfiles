# Prometheus

Minimal setup to run a local Prometheus instance scraping:
- `localhost:9100` — node_exporter (this Mac)
- `raspberrypi:9101` — rpi-exporter (Raspberry Pi)

## Install

```bash
brew install prometheus
```

## Usage

```bash
prometheus --config.file=prometheus.yml
```

Edit `prometheus.yml` to change targets (e.g. different hostname for the Pi).
UI available at `http://localhost:9090`.
