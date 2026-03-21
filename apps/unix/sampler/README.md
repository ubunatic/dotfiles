# sampler dashboard for rpi-exporter

Terminal dashboard using [sampler](https://github.com/sqshq/sampler).

Queries the rpi-exporter `/metrics` endpoint directly — **no Prometheus needed**.

## Install

```bash
# macOS
brew install sampler

# Linux
curl -Lo sampler https://github.com/sqshq/sampler/releases/latest/download/sampler-linux-amd64
chmod +x sampler && sudo mv sampler /usr/local/bin/
```

## Usage

```bash
RPI_HOST=raspberrypi sampler -c config.yaml
# or
RPI_HOST=192.168.1.10 sampler -c config.yaml
```

## Panels

- **Temperature** — SoC temperature in °C (live graph)
- **ARM Clock** — ARM and core clock in GHz (live graph)
- **Voltage** — core and SDRAM_C voltage (live graph)
- **Status bar** — throttled status + current temp
