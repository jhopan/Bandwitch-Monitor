#!/bin/sh
set -eu
CTRL=$(dirname "$0")/../luci/controller/bandwidth_control.lua
CBI=$(dirname "$0")/../luci/model/cbi/bandwidth_control.lua
grep -q last_seen= "$CTRL"
grep -q 'last.template="bandwidth_control/live_value"' "$CBI"
printf 'ok\n'
