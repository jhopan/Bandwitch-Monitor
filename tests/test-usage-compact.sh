#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'Usage / quota' "$FILE"
grep -q 'string.format("%s / %s GB (%d%%)"' "$FILE"
! grep -q 'left %s' "$FILE"
printf 'ok\n'
