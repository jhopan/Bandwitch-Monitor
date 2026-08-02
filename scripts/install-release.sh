#!/bin/sh
# Install latest release IPK. Router needs WAN access.
set -eu
REPO=${REPO:-jhopan/Bandwitch-Monitor}
API="https://api.github.com/repos/$REPO/releases/latest"
URL=$(wget -qO- "$API" | jsonfilter -e '@.assets[*].browser_download_url' | grep 'bandwidth-control_.*\.ipk$' | head -n1)
[ -n "$URL" ] || { echo "No release IPK found" >&2; exit 1; }
wget -O /tmp/bandwidth-control.ipk "$URL"
opkg install /tmp/bandwidth-control.ipk
/etc/init.d/bandwidth-control enable
/etc/init.d/bandwidth-control restart
printf 'Installed. Open LuCI: Services > Bandwidth Control\n'
