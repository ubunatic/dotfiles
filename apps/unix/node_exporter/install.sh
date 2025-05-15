#!/usr/bin/env bash
set -o errexit

# example: https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.darwin-arm64.tar.gz

here="$(pwd)"
version="1.9.1"
arch="$(uname -s)-$(uname -m)"
archive="node_exporter-$version.$arch.tar.gz"
url="https://github.com/prometheus/node_exporter/releases/download/v$version/$archive"
binary="$here/bin/node_exporter"

# MacOS
plist="bin/node_exporter.plist"
launchd="$HOME/Library/LaunchAgents"

# Linux: Simply use the package managers!

wget --continue "$url"
tar -xzf "$archive"

rm -rf bin
mv "node_exporter-$version.$arch" bin

chmod 777 "$binary"
sed -e "s|/usr/local/bin/node_exporter|$binary|g" node_exporter.plist > "$plist"

echo "---"
echo "Please add $binary to your startup apps or services"
echo "---"

echo -n "Run $binary now? [y/N] "
if read -r k && test "$k" = "y"
then ($binary; echo "done") || true # ignore ^C
     echo "node_exporter stopped"
else echo "node_exporter test skipped"
fi

if test "$(uname -s)" = "Darwin"
then
     echo -n "install $plist to $launchd? [y/N] "
     if read -r k && test "$k" = "y"
     then echo cp "$plist" "$launchd/"
     else echo "installed aborted"
     fi
     if touch -c "$launchd/node_exporter.plist"
     then echo "node_exporter.plist installed"
     else echo "install failed"; exit 1
     fi
     echo "Please start node_exporter using launchctl"
fi

# curl http://localhost:9100/metrics
