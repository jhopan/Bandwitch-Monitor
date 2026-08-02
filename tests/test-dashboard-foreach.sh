#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
! grep -q 'for s in m\.uci:foreach' "$FILE"
grep -q 'm\.uci:foreach("bandwidth-control", "device", function(s)' "$FILE"
printf 'ok\n'
