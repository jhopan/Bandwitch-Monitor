#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
MAC=aa:bb:cc:dd:ee:ff
BC_STATE="$TMP" BC_RAW='0|0|0' "$ROOT/files/usr/libexec/bandwidth-control/check" reset "$MAC"
BC_STATE="$TMP" BC_RAW='1200000000000|300000000000|1500000000000' "$ROOT/files/usr/libexec/bandwidth-control/check" sync "$MAC"
[ "$(BC_STATE="$TMP" "$ROOT/files/usr/libexec/bandwidth-control/check" usage "$MAC")" = '1200000000000|300000000000|1500000000000' ]
printf 'ok\n'
