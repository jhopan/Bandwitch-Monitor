#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/view/bandwidth_control/styles.htm
grep -q 'nth-child(3)' "$FILE"
grep -q 'nth-child(4)' "$FILE"
grep -q 'nth-child(9)' "$FILE"
grep -q 'nth-child(11)' "$FILE"
grep -q 'text-align:center' "$FILE"
printf 'ok\n'
