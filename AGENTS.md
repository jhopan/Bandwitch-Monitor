# Bandwidth Control Agent Guide

Read `PRD.md`, `TECHNICAL-DESIGN.md`, `ROADMAP.md`, then current source before changing code.

## Project

OpenWrt LuCI IPK. Per-MAC and group data quotas. `nlbwmon` provides RX/TX counters; nftables blocks source MAC after quota is reached.

## Non-negotiable rules

- Test first. Add a shell regression test in `tests/` before changing behavior.
- Run every test: `for test in tests/*.sh; do sh "$test"; done`.
- Build: `./build-ipk.sh`.
- Bump `Version:` in `CONTROL/control` for every installable update. `opkg` skips same-version IPKs.
- Install normal update: `opkg install /tmp/bandwidth-control_<version>_all.ipk`. Do not use `--force-reinstall` except deliberate destructive testing.
- Preserve `/etc/config/bandwidth-control`; it is listed in `CONTROL/conffiles`.
- Never bundle architecture-specific `nlbwmon` in this IPK. It must match target OpenWrt release and architecture.
- Keep quota identity MAC-based. IP/hostname are display/history only.
- nft block chain must run at `priority filter - 1`, before fw4 accepts LAN-to-WAN traffic.
- `Reset now` must reset baseline and clear only `quota` blocks, never manual blocks.
- Do not use `window.location.reload()` after form actions. It can repeat action endpoints. Auto-refresh must navigate to main page.

## Layout

```text
CONTROL/                         IPK metadata, conffiles, postinstall
files/etc/config/                UCI defaults
files/etc/init.d/                procd service
files/usr/libexec/.../check      accounting, baseline, block engine
luci/controller/                 download/restore routes
luci/model/cbi/                  LuCI form
luci/view/                       LuCI templates/styles
scripts/                         installer helper
tests/                           POSIX shell tests
build-ipk.sh                     gzip IPK builder
dist/                            generated IPK; latest only
```

## Test targets

- Local shell tests validate parsing, quotas, nft syntax, reset, config preservation, UI safeguards.
- STB smoke test:
  ```sh
  /etc/init.d/nlbwmon status
  /etc/init.d/bandwidth-control status
  nlbw -c csv -g mac -o mac -q
  /usr/libexec/bandwidth-control/check usage <MAC>
  nft list table inet bandwidth_control
  ```
- LuCI test: add DHCP device, set `0.1` GB, create traffic, wait 30–90 seconds, verify usage, quota block, unblock, reset.

## Known behavior

`nlbwmon` refreshes around 30 seconds. Quota worker checks every 60 seconds. LuCI refreshes every 30 seconds when no input is being edited. Current project requires real traffic to validate quota; raw `nlbwmon` values are lifetime/current-period counters, while displayed usage is `raw - baseline`.

## Docs maintenance

Update `README.md`, `PRD.md`, `TECHNICAL-DESIGN.md`, or `ROADMAP.md` whenever behavior, packaging, architecture, or roadmap changes.

No credentials, router passwords, private IP-specific secrets, backups, or runtime state in Git.

## Git

Use conventional, scoped commits. Push `main`. GitHub Actions builds artifacts on push and publishes releases on tags `v*`.