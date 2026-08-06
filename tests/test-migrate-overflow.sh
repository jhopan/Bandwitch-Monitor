#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
MAC=aa:bb:cc:dd:ee:ff
printf '100|20|120\n' > "$TMP/$MAC.baseline"
printf '2147483647|30|2147483647\n' > "$TMP/$MAC.used"
printf '4000000000|100|4000000100\n' > "$TMP/$MAC.last_raw"
BC_STATE="$TMP" BC_RAW='5000000000|200|5000000200' "$ROOT/files/usr/libexec/bandwidth-control/check" migrate "$MAC"
[ "$(cat "$TMP/$MAC.used")" = '4999999900|30|5000000080' ]

# Total can overflow while RX/TX independently remain below 2 GiB.
printf '100|200|2147483647\n' > "$TMP/$MAC.used"
printf '0|0|0\n' > "$TMP/$MAC.baseline"
BC_STATE="$TMP" BC_RAW='100|200|5000000000' "$ROOT/files/usr/libexec/bandwidth-control/check" migrate "$MAC"
[ "$(cat "$TMP/$MAC.used")" = '100|200|5000000000' ]
printf 'ok\n'
