#\!/usr/bin/env python3
"""
macmon-exporter: Apple Silicon Prometheus exporter
Wraps `macmon pipe` and exposes metrics on HTTP port 9102.
"""

import argparse
import json
import subprocess
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import Dict, Any, Optional


class MetricsCollector:
    """Thread-safe collector for macmon metrics."""

    def __init__(self):
        self._lock = threading.Lock()
        self._metrics: Dict[str, float] = {}

    def update(self, data: Dict[str, Any]) -> None:
        """Update metrics from parsed JSON line."""
        with self._lock:
            # CPU metrics
            if "ecpu_usage" in data and len(data["ecpu_usage"]) > 1:
                self._metrics["apple_cpu_ecpu_usage_ratio"] = data["ecpu_usage"][1]
            if "pcpu_usage" in data and len(data["pcpu_usage"]) > 1:
                self._metrics["apple_cpu_pcpu_usage_ratio"] = data["pcpu_usage"][1]

            # GPU metrics
            if "gpu_usage" in data and len(data["gpu_usage"]) > 1:
                self._metrics["apple_gpu_usage_ratio"] = data["gpu_usage"][1]

            # Power metrics
            self._metrics["apple_ane_power_watts"] = data.get("ane_power", 0.0)
            self._metrics["apple_cpu_power_watts"] = data.get("cpu_power", 0.0)
            self._metrics["apple_gpu_power_watts"] = data.get("gpu_power", 0.0)
            self._metrics["apple_sys_power_watts"] = data.get("sys_power", 0.0)

            # Memory metrics
            memory = data.get("memory", {})
            self._metrics["apple_ram_used_bytes"] = memory.get("ram_usage", 0)
            self._metrics["apple_ram_total_bytes"] = memory.get("ram_total", 0)
            self._metrics["apple_swap_used_bytes"] = memory.get("swap_usage", 0)

            # Temperature metrics
            temp = data.get("temp", {})
            self._metrics["apple_cpu_temp_celsius"] = temp.get("cpu_temp_avg", 0.0)
            self._metrics["apple_gpu_temp_celsius"] = temp.get("gpu_temp_avg", 0.0)

    def get_metrics(self) -> Dict[str, float]:
        """Return a copy of current metrics."""
        with self._lock:
            return self._metrics.copy()


class MacmonReader(threading.Thread):
    """Background thread that reads macmon output."""

    def __init__(self, collector: MetricsCollector, interval_ms: int = 1000):
        super().__init__(daemon=True)
        self.collector = collector
        self.interval_ms = interval_ms
        self._stop = False

    def run(self) -> None:
        """Run macmon pipe and parse JSON output."""
        try:
            cmd = ["macmon", "pipe", f"--interval", str(self.interval_ms)]
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
            )
        except FileNotFoundError:
            print("Error: macmon not found. Install with: brew install macmon", file=sys.stderr)
            sys.exit(1)

        try:
            for line in process.stdout:
                if self._stop:
                    break
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                    self.collector.update(data)
                except json.JSONDecodeError as e:
                    print(f"Warning: Failed to parse JSON: {e}", file=sys.stderr)
        except Exception as e:
            print(f"Error reading macmon output: {e}", file=sys.stderr)
        finally:
            try:
                process.terminate()
                process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()

    def stop(self) -> None:
        """Signal thread to stop."""
        self._stop = True


class MetricsHandler(BaseHTTPRequestHandler):
    """HTTP request handler for /metrics endpoint."""

    # Shared collector instance
    collector: Optional[MetricsCollector] = None

    def do_GET(self) -> None:
        """Handle GET requests."""
        if self.path == "/metrics":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.end_headers()

            metrics = self.collector.get_metrics()
            output = []

            # Emit metrics in Prometheus text format
            for name, value in sorted(metrics.items()):
                # Format as integer for byte counts, float otherwise
                if "bytes" in name:
                    output.append(f"{name} {int(value)}")
                else:
                    output.append(f"{name} {value:.6g}")

            self.wfile.write("\n".join(output).encode("utf-8"))
            if output:
                self.wfile.write(b"\n")
        else:
            self.send_response(404)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Not Found\n")

    def log_message(self, format, *args) -> None:
        """Suppress default logging."""
        pass


def main() -> None:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Apple Silicon Prometheus exporter (wraps macmon pipe)"
    )
    parser.add_argument(
        "--port",
        type=int,
        default=9102,
        help="HTTP server port (default: 9102)",
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=1000,
        help="macmon update interval in milliseconds (default: 1000)",
    )
    args = parser.parse_args()

    # Create collector and reader
    collector = MetricsCollector()
    reader = MacmonReader(collector, interval_ms=args.interval)
    reader.start()

    # Set up HTTP server
    MetricsHandler.collector = collector
    server = HTTPServer(("0.0.0.0", args.port), MetricsHandler)

    print(f"Starting macmon exporter on http://0.0.0.0:{args.port}/metrics", file=sys.stderr)
    print("Press Ctrl+C to exit", file=sys.stderr)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...", file=sys.stderr)
        reader.stop()
        server.shutdown()


if __name__ == "__main__":
    main()
