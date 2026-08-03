#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/view/bandwidth_control/styles.htm
grep -q 'setTimeout' "$FILE"
grep -q 'window.location.href' "$FILE"
! grep -q 'window.location.reload' "$FILE"
printf 'ok\n'
