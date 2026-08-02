#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/files/usr/libexec/bandwidth-control/check
grep -q 'priority filter - 1' "$FILE"
grep -q 'nft delete table inet bandwidth_control' "$FILE"
printf 'ok\n'
