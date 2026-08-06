#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'local savedlease=dev:option(DummyValue' "$FILE"
grep -q 'local editmode=dev:option(Flag,"edit_mode"' "$FILE"
grep -q 'newmac:depends("edit_mode","1")' "$FILE"
grep -q 'Edit MAC then Save & Apply' "$FILE"
printf 'ok\n'
