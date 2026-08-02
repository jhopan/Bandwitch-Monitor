#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/files/usr/libexec/bandwidth-control/check
grep -q '^table inet bandwidth_control {' "$FILE"
grep -q '^ chain forward {' "$FILE"
printf 'ok\n'
