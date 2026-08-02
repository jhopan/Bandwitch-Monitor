#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/model/cbi/bandwidth_control.lua
! grep -q 'self.keylist\[value\]' "$FILE"
! grep -q 'value:upper' "$FILE"
printf 'ok\n'
