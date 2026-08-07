#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'function name.write' "$FILE"
grep -q 'value and value ~= ""' "$FILE"
printf 'ok\n'
