#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
MAC=aa:bb:cc:dd:ee:ff
BC_STATE="$TMP" BC_RAW='3500000000|200000000|3700000000' "$ROOT/files/usr/libexec/bandwidth-control/check" stabilize "$MAC"
test -f "$TMP/$MAC.migrated"
test -f "$TMP/$MAC.baseline"
test -f "$TMP/$MAC.reset_at"
[ "$(cat "$TMP/$MAC.used")" = '3500000000|200000000|3700000000' ]
BC_STATE="$TMP" BC_RAW='3500000100|200000100|3700000200' "$ROOT/files/usr/libexec/bandwidth-control/check" stabilize "$MAC"
[ "$(cat "$TMP/$MAC.used")" = '3500000000|200000000|3700000000' ]
printf 'ok\n'
