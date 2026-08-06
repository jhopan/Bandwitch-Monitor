#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CBI="$ROOT/luci/model/cbi/bandwidth_control.lua"
CSS="$ROOT/luci/view/bandwidth_control/styles.htm"
! grep -q 'Device MAC (locked)' "$CBI"
! grep -q 'DHCP device (locked)' "$CBI"
! grep -q 'Each saved device is locked' "$CBI"
grep -q 'Current device' "$CBI"
grep -q 'bc-mac-edit-select' "$CSS"
printf 'ok\n'
