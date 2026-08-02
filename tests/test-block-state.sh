#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/state"
cat > "$TMP/bin/nft" <<'EOF'
#!/bin/sh
exit 0
EOF
chmod +x "$TMP/bin/nft"
PATH="$TMP/bin:$PATH" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" block AA:BB:CC:DD:EE:FF manual
[ "$(cat "$TMP/state/aa:bb:cc:dd:ee:ff.reason")" = manual ]
PATH="$TMP/bin:$PATH" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" status AA:BB:CC:DD:EE:FF | grep -q '^blocked|manual|'
PATH="$TMP/bin:$PATH" BC_STATE="$TMP/state" "$ROOT/files/usr/libexec/bandwidth-control/check" unblock AA:BB:CC:DD:EE:FF
[ ! -e "$TMP/state/aa:bb:cc:dd:ee:ff.blocked" ]
[ ! -e "$TMP/state/aa:bb:cc:dd:ee:ff.reason" ]
printf 'ok\n'
