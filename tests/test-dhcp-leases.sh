#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/dhcp.leases" <<'EOF'
1780430768 c0:18:50:5a:3b:fe 192.168.13.151 LAPTOP-3FBHMC46 01:c0:18:50:5a:3b:fe
1780430768 02:11:22:33:44:55 192.168.13.152 * *
EOF
BC_LEASES="$TMP/dhcp.leases" "$ROOT/files/usr/libexec/bandwidth-control/check" leases > "$TMP/out"
grep -qx 'c0:18:50:5a:3b:fe|192.168.13.151|LAPTOP-3FBHMC46' "$TMP/out"
grep -qx '02:11:22:33:44:55|192.168.13.152|unknown' "$TMP/out"
printf 'ok\n'
