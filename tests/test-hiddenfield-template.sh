#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test -s "$ROOT/luci/view/cbi/hiddenfield.htm"
grep -q 'type="hidden"' "$ROOT/luci/view/cbi/hiddenfield.htm"
printf 'ok\n'
