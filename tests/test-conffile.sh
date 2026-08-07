#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
grep -q 'CONTROL/conffiles' "$ROOT/build-ipk.sh"
printf 'ok\n'
