#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
grep -q 'local savedlease=dev:option(DummyValue' "$FILE"
grep -q 'newmac:depends("edit_mac","1")' "$FILE"
grep -q 'Select replacement DHCP device' "$FILE"
printf 'ok\n'
