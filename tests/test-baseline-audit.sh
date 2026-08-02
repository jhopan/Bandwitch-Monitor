#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/state"
cat > "$TMP/bin/nlbw" <<'EOF'
#!/bin/sh
printf 'mac\tconns\trx_bytes\trx_pkts\ttx_bytes\ttx_pkts\n'
printf 'aa:bb:cc:dd:ee:ff\t1\t600\t0\t400\t0\n'
EOF
cat > "$TMP/bin/nft" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "$TMP/bin/nlbw" "$TMP/bin/nft"
PATH="$TMP/bin:$PATH" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" reset AA:BB:CC:DD:EE:FF
[ "$(PATH="$TMP/bin:$PATH" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" used AA:BB:CC:DD:EE:FF)" = 0 ]
PATH="$TMP/bin:$PATH" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" block AA:BB:CC:DD:EE:FF manual
grep -q '|block|manual|' "$TMP/state/audit.log"
printf 'ok\n'
