#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CBI="$ROOT/luci/model/cbi/bandwidth_control.lua"
CSS="$ROOT/luci/view/bandwidth_control/styles.htm"
grep -q 'm:append(Template("bandwidth_control/styles"))' "$CBI"
grep -q 'overflow-x: auto' "$CSS"
grep -q '@media (max-width: 900px)' "$CSS"
printf 'ok\n'
