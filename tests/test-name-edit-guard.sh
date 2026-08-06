#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'function name.write' "$FILE"
grep -q 'value and value ~= ""' "$FILE"
grep -q 'finish_edit' "$FILE"
grep -q 'if s.finish_edit == "1"' "$FILE"
printf 'ok\n'
