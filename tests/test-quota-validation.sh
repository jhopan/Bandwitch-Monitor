#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -Fq 'v:match("^%d+%.?%d*$")' "$FILE"
printf 'ok\n'
