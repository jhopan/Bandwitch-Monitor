#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
! grep -q 'Visible only after Edit MAC' "$FILE"
printf 'ok\n'
