#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
! grep -Fq 'gmatch("[^|]*")' "$FILE"
grep -Fq 'gmatch("[^|]+")' "$FILE"
printf 'ok\n'
