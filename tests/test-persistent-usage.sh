#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
MAC=aa:bb:cc:dd:ee:ff

BC_STATE="$TMP" BC_RAW='100|20|120' "$ROOT/files/usr/libexec/bandwidth-control/check" reset "$MAC"
BC_STATE="$TMP" BC_RAW='150|30|180' "$ROOT/files/usr/libexec/bandwidth-control/check" sync "$MAC"
[ "$(BC_STATE="$TMP" "$ROOT/files/usr/libexec/bandwidth-control/check" used "$MAC")" = 60 ]

# nlbwmon restart: raw counters restart at lower values. Usage must keep prior total.
BC_STATE="$TMP" BC_RAW='10|5|15' "$ROOT/files/usr/libexec/bandwidth-control/check" sync "$MAC"
[ "$(BC_STATE="$TMP" "$ROOT/files/usr/libexec/bandwidth-control/check" used "$MAC")" = 75 ]
printf 'ok\n'
