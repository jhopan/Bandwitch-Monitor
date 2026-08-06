#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CBI="$ROOT/luci/model/cbi/bandwidth_control.lua"
STYLE="$ROOT/luci/view/bandwidth_control/styles.htm"
grep -q 'Usage / quota' "$CBI"
grep -q 'return string.format("%s / %s GB",fmt(n),q)' "$CBI"
grep -q 'bc-device-tabs' "$STYLE"
grep -q 'data-bc-tab="devices"' "$STYLE"
grep -q 'data-bc-tab="usage"' "$STYLE"
grep -q 'data-bc-tab="actions"' "$STYLE"
printf 'ok\n'
