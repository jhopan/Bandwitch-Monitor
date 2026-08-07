#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUT="dist"
STAGE=".build-stage"
trap 'rm -rf "$STAGE"' EXIT
rm -rf "$OUT" "$STAGE"
mkdir -p "$OUT" "$STAGE/control" "$STAGE/data"
cp "$ROOT/CONTROL/control" "$STAGE/control/control"
cp "$ROOT/CONTROL/conffiles" "$STAGE/control/conffiles"
cp "$ROOT/CONTROL/postinst" "$STAGE/control/postinst"
[ -f "$ROOT/CONTROL/prerm" ] && cp "$ROOT/CONTROL/prerm" "$STAGE/control/prerm" || true
cp -a "$ROOT/files/." "$STAGE/data/"
mkdir -p "$STAGE/data/usr/lib/lua/luci"
cp -a "$ROOT/luci/controller" "$STAGE/data/usr/lib/lua/luci/"
cp -a "$ROOT/luci/model" "$STAGE/data/usr/lib/lua/luci/"
cp -a "$ROOT/luci/view" "$STAGE/data/usr/lib/lua/luci/"
find "$STAGE/data/usr/lib/lua/luci/view" -name "*.htm" -exec sed -i 's/\r//' {} \;
chmod 0755 "$STAGE/control/postinst" "$STAGE/data/etc/init.d/bandwidth-control" "$STAGE/data/usr/libexec/bandwidth-control/check"
[ -f "$STAGE/control/prerm" ] && chmod 0755 "$STAGE/control/prerm" || true
printf '2.0\n' > "$STAGE/debian-binary"
tar -C "$STAGE/control" -czf "$STAGE/control.tar.gz" .
tar -C "$STAGE/data" -czf "$STAGE/data.tar.gz" .
VERSION=$(awk -F': ' '/^Version:/{print $2}' "$ROOT/CONTROL/control")
tar -C "$STAGE" -czf "$OUT/bandwidth-control_${VERSION}_all.ipk" debian-binary control.tar.gz data.tar.gz
printf 'Built %s\n' "$OUT/bandwidth-control_${VERSION}_all.ipk"