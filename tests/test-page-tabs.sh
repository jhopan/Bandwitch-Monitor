#!/bin/sh
set -eu
FILE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/luci/view/bandwidth_control/styles.htm
grep -q 'data-bc-page="dashboard"' "$FILE"
grep -q 'data-bc-page="devices"' "$FILE"
grep -q 'data-bc-page="logs"' "$FILE"
grep -q 'DOMContentLoaded' "$FILE"
! grep -q 'data-bc-tab="usage"' "$FILE"
printf 'ok\n'
