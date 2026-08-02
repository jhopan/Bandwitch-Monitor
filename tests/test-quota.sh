#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/etc/config" "$TMP/etc/bandwidth-control"

cat > "$TMP/bin/uci" <<'EOF'
#!/bin/sh
case "$*" in
  *'show bandwidth-control')
    cat <<OUT
bandwidth-control.main=main
bandwidth-control.main.enabled='1'
bandwidth-control.main.interval='60'
bandwidth-control.device1=device
bandwidth-control.device1.mac='AA:BB:CC:DD:EE:FF'
bandwidth-control.device1.quota_gb='1'
bandwidth-control.device1.enabled='1'
OUT
  ;;
  *'get bandwidth-control.main.enabled') echo 1 ;;
  *'get bandwidth-control.device1.mac') echo AA:BB:CC:DD:EE:FF ;;
  *'get bandwidth-control.device1.enabled') echo 1 ;;
  *'get bandwidth-control.device1.quota_gb') echo 1 ;;
esac
EOF
cat > "$TMP/bin/nlbw" <<'EOF'
#!/bin/sh
printf 'mac\tconns\trx_bytes\trx_pkts\ttx_bytes\ttx_pkts\n'
printf 'aa:bb:cc:dd:ee:ff\t1\t800000000\t0\t400000000\t0\n'
EOF
cat > "$TMP/bin/nft" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$NFT_LOG"
EOF
chmod +x "$TMP/bin/uci" "$TMP/bin/nlbw" "$TMP/bin/nft"

grep -q 'ether saddr @blocked_macs drop;' "$ROOT/files/usr/libexec/bandwidth-control/check"

PATH="$TMP/bin:$PATH" NFT_LOG="$TMP/nft.log" BC_CONFIG="$TMP/etc/config/bandwidth-control" BC_STATE="$TMP/etc/bandwidth-control" "$ROOT/files/usr/libexec/bandwidth-control/check" check
grep -q 'add element inet bandwidth_control blocked_macs { aa:bb:cc:dd:ee:ff }' "$TMP/nft.log"
PATH="$TMP/bin:$PATH" NFT_LOG="$TMP/nft.log" BC_CONFIG="$TMP/etc/config/bandwidth-control" BC_STATE="$TMP/etc/bandwidth-control" "$ROOT/files/usr/libexec/bandwidth-control/check" unblock AA:BB:CC:DD:EE:FF
grep -q 'delete element inet bandwidth_control blocked_macs { aa:bb:cc:dd:ee:ff }' "$TMP/nft.log"
printf 'ok\n'
