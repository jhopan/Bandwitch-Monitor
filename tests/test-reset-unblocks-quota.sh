#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/state"
cat > "$TMP/bin/nft" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$NFT_LOG"
EOF
cat > "$TMP/bin/nlbw" <<'EOF'
#!/bin/sh
printf 'mac\tconns\trx_bytes\trx_pkts\ttx_bytes\ttx_pkts\n'
printf 'aa:bb:cc:dd:ee:ff\t1\t500\t0\t200\t0\n'
EOF
chmod +x "$TMP/bin/nft" "$TMP/bin/nlbw"
PATH="$TMP/bin:$PATH" NFT_LOG="$TMP/nft.log" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" block AA:BB:CC:DD:EE:FF quota
PATH="$TMP/bin:$PATH" NFT_LOG="$TMP/nft.log" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" reset AA:BB:CC:DD:EE:FF
[ ! -e "$TMP/state/aa:bb:cc:dd:ee:ff.blocked" ]
grep -q 'delete element inet bandwidth_control blocked_macs { aa:bb:cc:dd:ee:ff }' "$TMP/nft.log"
printf 'ok\n'
