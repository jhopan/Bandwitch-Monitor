#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/view/bandwidth_control/styles.htm
! grep -q "document.querySelector(':focus')" "$FILE"
grep -q 'if (dirty) return setTimeout(poll, 30000);' "$FILE"
printf 'ok\n'
