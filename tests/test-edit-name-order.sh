#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
NAME=$(grep -n 'local name=dev:option' "$FILE" | cut -d: -f1)
EDIT=$(grep -n 'local editmac=dev:option' "$FILE" | cut -d: -f1)
STATUS=$(grep -n 'local stat=dev:option' "$FILE" | cut -d: -f1)
[ "$NAME" -lt "$EDIT" ]
[ "$EDIT" -lt "$STATUS" ]
grep -q 'editmac.inputtitle=translate("Edit")' "$FILE"
printf 'ok\n'
