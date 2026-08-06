#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CTRL="$ROOT/luci/controller/bandwidth_control.lua"
STYLE="$ROOT/luci/view/bandwidth_control/styles.htm"
grep -q 'call("status")' "$CTRL"
grep -q 'function status()' "$CTRL"
grep -q 'application/json' "$CTRL"
grep -q 'fetch(statusUrl' "$STYLE"
! grep -q 'window.location.href = window.location.pathname' "$STYLE"
printf 'ok\n'
