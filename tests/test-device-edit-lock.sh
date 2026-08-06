#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'local function unique_mac' "$FILE"
grep -q 'locked to its MAC' "$FILE"
grep -q 'newmac.cfgvalue' "$FILE"
grep -q 'Click Edit MAC first' "$FILE"
grep -q 'This MAC already belongs' "$FILE"
printf 'ok\n'
