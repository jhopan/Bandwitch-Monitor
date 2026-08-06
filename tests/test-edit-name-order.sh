#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
EDIT=$(grep -n 'local editmac=dev:option' "$FILE" | cut -d: -f1)
STATUS=$(grep -n 'local stat=dev:option' "$FILE" | cut -d: -f1)
NAME=$(grep -n 'local name=dev:option' "$FILE" | cut -d: -f1)
[ "$EDIT" -lt "$STATUS" ]
[ "$STATUS" -lt "$NAME" ]
grep -q 'editmac.inputtitle=translate("Edit")' "$FILE"
grep -q 'name.template="bandwidth_control/edit_name"' "$FILE"
printf 'ok\n'
