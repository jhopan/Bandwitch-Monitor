#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/view/bandwidth_control/manage.htm
! grep -q '<form' "$FILE"
! grep -q 'required=' "$FILE"
grep -q 'formaction=' "$FILE"
printf 'ok\n'
