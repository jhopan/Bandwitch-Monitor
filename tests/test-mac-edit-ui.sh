#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILE="$ROOT/luci/model/cbi/bandwidth_control.lua"
VIEW="$ROOT/luci/view/bandwidth_control/mac_edit.htm"
grep -q 'local savedlease=dev:option(DummyValue' "$FILE"
grep -q 'newmac.template="bandwidth_control/mac_edit"' "$FILE"
! grep -q 'cbi/hiddenfield' "$FILE"
grep -q 'edit_mode' "$VIEW"
grep -q 'Combobox' "$VIEW"
printf 'ok\n'
