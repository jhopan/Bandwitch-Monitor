<div align="center">

# 🚀 Bandwidth Control

**The Ultimate OpenWrt Per-MAC & Group Data Quota Controller with LuCI**

[![OpenWrt](https://img.shields.io/badge/OpenWrt-24.10%2B-blue?style=for-the-badge)](https://openwrt.org/)
[![Architecture](https://img.shields.io/badge/Architecture-all-lightgrey?style=for-the-badge)](#install)
[![LuCI](https://img.shields.io/badge/GUI-LuCI-green?style=for-the-badge)](#usage)
[![IPK](https://img.shields.io/badge/Package-IPK-orange?style=for-the-badge)](dist/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 💡 **Love this project?** Please consider giving it a ⭐ **Star** on GitHub to help others find it! 

</div>

---

Manage internet usage fairly without complex captive portals. Set precise data limits for individual devices or shared groups. Once the limit is reached, access is automatically blocked via `nftables` while local networking remains intact.

## ✨ Features

- **🎯 Precision Per-MAC Quota**: Support for decimal GB formats (`0.1`, `0.5`, `1.5` GB).
- **👥 Shared Quota Groups**: Pool devices together. See total usage, remaining quota, RX/TX, and member count directly in LuCI.
- **🛡️ Bulletproof Enforcement**: Auto-blocks via `nftables` when quota is hit. Verified on live OpenWrt AP + LAN bridge setups.
- **📊 Terabyte-Scale Accounting**: Powered by `nlbwmon` with persistent 64-bit-safe counters. Survives router reboots!
- **⚡ Smart DHCP Device Picker**: Clean UI showing MAC + IP Address. Dropdowns appear only when editing. Auto-prevents duplicate MACs.
- **🔄 Flexible Reset Cycles**: Choose between global monthly resets or per-device rolling periods (e.g., every 7 or 30 days).
- **💾 Automated Backups**: Safely backs up your config and usage state every hour to `/etc/config/bandwidth-control.hourly-backup`.
- **🛠️ Total Management**: Manual block/unblock, static IP lease toggles, detailed audit logs, and one-click manual backup/restore.
- **⏱️ Live Dashboard**: Usage refreshes every 30 seconds smoothly without annoying page reloads.

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
dist/bandwidth-control_1.0.2-1_all.ipk
```

## Download and Release

Every push to `main` runs shell tests and builds an IPK artifact in GitHub Actions. A tag such as `v1.0.0` creates a GitHub Release with:

```text
bandwidth-control_*.ipk
SHA256SUMS
```

Download release IPK from:

```text
https://github.com/jhopan/Bandwitch-Monitor/releases
```

On an internet-connected OpenWrt router, install latest release:

```sh
wget -O /tmp/install-bandwidth-control.sh https://raw.githubusercontent.com/jhopan/Bandwitch-Monitor/main/scripts/install-release.sh
sh /tmp/install-bandwidth-control.sh
```

`nlbwmon` is not bundled because it must match router OpenWrt release and architecture. Install it first:

```sh
opkg update
opkg install nlbwmon
```

Verify downloaded asset:

```sh
sha256sum -c SHA256SUMS
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

Live verification completed:

```text
Quota: 0.1 GB
Traffic source: client behind LAN-to-LAN AP bridge
Accounting: nlbwmon RX + TX per MAC
Enforcement: nftables source-MAC drop before fw4 LAN-to-WAN accept rules
Result: internet access blocked after quota reached
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

## AI and Development Handoff

Read these before changing behavior:

- `AGENTS.md` — rules, invariants, test and packaging workflow
- `PRD.md` — product requirements and acceptance criteria
- `TECHNICAL-DESIGN.md` — architecture, state model, nftables ordering
- `ROADMAP.md` — shipped work and next priorities
- `DEVELOPMENT.md` — local build, STB deploy, troubleshooting, release workflow

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
