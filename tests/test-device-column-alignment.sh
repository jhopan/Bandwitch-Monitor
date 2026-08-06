#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/view/bandwidth_control/styles.htm
grep -q 'nth-child(1).*text-align:center' "$FILE"
grep -q 'nth-child(5).*text-align:center' "$FILE"
grep -q 'nth-child(6).*text-align:center' "$FILE"
printf 'ok\n'
