#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
! grep -q 'tonumber((.*:gsub' "$FILE"
grep -q 'tonumber' "$FILE"
printf 'ok\n'
