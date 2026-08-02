<div align="center">

# Bandwidth Control

**OpenWrt per-MAC and group data quota control with LuCI**

[![OpenWrt](https://img.shields.io/badge/OpenWrt-24.10%2B-blue?style=for-the-badge)](https://openwrt.org/)
[![Architecture](https://img.shields.io/badge/Architecture-all-lightgrey?style=for-the-badge)](#install)
[![LuCI](https://img.shields.io/badge/GUI-LuCI-green?style=for-the-badge)](#usage)
[![IPK](https://img.shields.io/badge/Package-IPK-orange?style=for-the-badge)](dist/)

</div>

## Features

- Per-MAC quota. Supports decimal GB: `0,1`, `0.5`, `1,5`.
- Shared quota groups.
- Download + upload accounting via `nlbwmon`.
- Auto block through nftables after quota is reached.
- Manual block, unblock, and reset quota baseline.
- DHCP lease picker. Quota stays attached to MAC if IP changes.
- Optional static DHCP lease button.
- Monthly global reset or per-device 7/30 day rolling reset.
- Usage details, last seen hostname/IP, block reason, timestamp.
- Audit log, backup, restore.

## Requirements

Target tested:

```text
OpenWrt 24.10.7
ZTE B860H
armsr/armv8
```

Runtime dependencies:

```text
nlbwmon
nftables-json
luci-base
luci-compat
```

## Install

Copy both IPKs to router. `nlbwmon` must match router OpenWrt release and architecture.

```sh
scp nlbwmon_*.ipk bandwidth-control_*.ipk root@ROUTER:/tmp/
ssh root@ROUTER '
opkg install /tmp/nlbwmon_*.ipk
opkg install /tmp/bandwidth-control_*.ipk
/etc/init.d/nlbwmon enable
/etc/init.d/nlbwmon start
/etc/init.d/bandwidth-control enable
/etc/init.d/bandwidth-control restart
'
```

Current local package:

```text
dist/bandwidth-control_1.0.0-1_all.ipk
```

## Usage

Open LuCI:

```text
Services → Bandwidth Control
```

1. Add device.
2. Select active DHCP lease.
3. Set quota, for example `0,1` GB for a quick test.
4. Enable device.
5. Save & Apply.

Quota checks every 60 seconds by default. When used bytes reach quota, source MAC is inserted into nftables `blocked_macs`.

## Test

Use `0,1` GB then download roughly 120–150 MB through router WAN. Verify:

```sh
nlbw -c csv -g mac -o mac -q
nft list table inet bandwidth_control
/usr/libexec/bandwidth-control/check status AA:BB:CC:DD:EE:FF
```

Expected status after quota is reached:

```text
blocked|quota|YYYY-MM-DD HH:MM:SS
```

Click **Unblock** from LuCI to restore access.

## Build

Windows Git Bash / Linux:

```sh
chmod +x build-ipk.sh
./build-ipk.sh
```

Output:

```text
dist/bandwidth-control_1.0.0-1_all.ipk
```

Run shell tests:

```sh
for test in tests/*.sh; do sh "$test"; done
```

## Data and Safety

- Runtime state: `/etc/bandwidth-control/`
- UCI config: `/etc/config/bandwidth-control`
- Backup exports both paths only.
- Restore accepts only these paths from `.tar.gz` backup.
- `nlbwmon` determines accounting period. Changing monthly reset applies at next period.

## Limits

- No speed limiter yet. Future speed shaping should use `tc`/CAKE separately.
- Captive portal redirect is not included. Blocked clients lose routed internet access.

## License

No license selected yet.
