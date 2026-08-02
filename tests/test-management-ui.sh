#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CBI="$ROOT/luci/model/cbi/bandwidth_control.lua"
CTRL="$ROOT/luci/controller/bandwidth_control.lua"
grep -q 'rolling_days' "$CBI"
grep -q 'audit' "$CTRL"
grep -q 'restore' "$CTRL"
printf 'ok\n'
