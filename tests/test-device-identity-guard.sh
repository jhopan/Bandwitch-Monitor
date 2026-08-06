#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'local function unique_mac' "$FILE"
grep -q 'Device MAC is locked' "$FILE"
grep -q 'dev.create' "$FILE"
printf 'ok\n'
