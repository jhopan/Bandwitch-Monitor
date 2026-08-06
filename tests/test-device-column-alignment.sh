#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/view/bandwidth_control/styles.htm
for n in 1 2 3 6 7 8; do grep -q "nth-child($n)" "$FILE"; done
grep -q 'text-align:center' "$FILE"
printf 'ok\n'
