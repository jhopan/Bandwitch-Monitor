#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
[ "$("$ROOT/files/usr/libexec/bandwidth-control/check" quota-bytes 0,5)" = 536870912 ]
[ "$("$ROOT/files/usr/libexec/bandwidth-control/check" quota-bytes 0.1)" = 107374182 ]
printf 'ok\n'
