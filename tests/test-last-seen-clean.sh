#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'Last seen' "$FILE"
grep -q 'return t$' "$FILE"
printf 'ok\n'
