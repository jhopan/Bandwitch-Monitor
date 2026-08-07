#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'Usage / quota' "$FILE"
grep -q 'string.format' "$FILE"
printf 'ok\n'
