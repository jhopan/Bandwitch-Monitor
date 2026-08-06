#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP"
for mac in aa:bb:cc:dd:ee:01 aa:bb:cc:dd:ee:02; do
  printf '0|0|0\n' > "$TMP/$mac.baseline"
  printf '0|0|0\n' > "$TMP/$mac.used"
  printf '0|0|0\n' > "$TMP/$mac.last_raw"
done
BC_STATE="$TMP" BC_RAW='100|20|120' "$ROOT/files/usr/libexec/bandwidth-control/check" sync aa:bb:cc:dd:ee:01
BC_STATE="$TMP" BC_RAW='50|10|60' "$ROOT/files/usr/libexec/bandwidth-control/check" sync aa:bb:cc:dd:ee:02
[ "$(BC_STATE="$TMP" "$ROOT/files/usr/libexec/bandwidth-control/check" group-usage aa:bb:cc:dd:ee:01 aa:bb:cc:dd:ee:02)" = '150|30|180' ]
printf 'ok\n'
