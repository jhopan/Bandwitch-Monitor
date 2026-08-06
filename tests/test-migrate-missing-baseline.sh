#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
MAC=aa:bb:cc:dd:ee:ff
# Historic state: RX/TX valid, total hit signed-32-bit cap, no baseline file.
printf '1915000000|804000000|2147483647\n' > "$TMP/$MAC.used"
printf '1915000000|804000000|2719000000\n' > "$TMP/$MAC.last_raw"
BC_STATE="$TMP" BC_RAW='1916000000|805000000|2721000000' "$ROOT/files/usr/libexec/bandwidth-control/check" migrate "$MAC"
[ "$(cat "$TMP/$MAC.used")" = '1916000000|805000000|2721000000' ]
printf 'ok\n'
