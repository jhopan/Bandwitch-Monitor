# Development Guide

## Prerequisites

Local: POSIX shell, `tar`, `awk`, `grep`. Windows Git Bash works. Target: OpenWrt with `nlbwmon`, nftables, LuCI.

## Local loop

```sh
chmod +x build-ipk.sh files/usr/libexec/bandwidth-control/check tests/*.sh
for test in tests/*.sh; do sh "$test"; done
./build-ipk.sh
```

Generated IPK uses `Version:` from `CONTROL/control`:

```text
dist/bandwidth-control_<version>_all.ipk
```

## STB deploy loop

```sh
scp dist/bandwidth-control_<version>_all.ipk stb-alias:/tmp/
ssh stb-alias '
opkg install /tmp/bandwidth-control_<version>_all.ipk
/etc/init.d/bandwidth-control restart
/etc/init.d/bandwidth-control status
'
```

Use `opkg install`, not `--force-reinstall`, for normal upgrades. `--force-reinstall` can reset/reapply package files and is only for explicit destructive tests.

## Test quota manually

1. Add client via DHCP picker.
2. Set quota `0.1` GB.
3. Click Reset now once.
4. Generate over 102.4 MB traffic through STB.
5. Wait 30–90 seconds.
6. Verify:

```sh
nlbw -c csv -g mac -o mac -q
/usr/libexec/bandwidth-control/check usage <MAC>
/usr/libexec/bandwidth-control/check status <MAC>
nft list table inet bandwidth_control
```

## Troubleshooting

| Symptom | Check |
|---|---|
| Usage is zero | Compare raw `nlbw` counter with baseline; verify client traffic routes through STB. |
| Blocked but internet works | nft chain must be `priority filter - 1`; inspect `nft list table inet bandwidth_control`. |
| Reset repeats | UI must navigate to main page, not reload prior action endpoint. |
| Config gone after update | Check version changed and `/usr/lib/opkg/info/bandwidth-control.conffiles` contains config path. |
| Client not listed | Check `/tmp/dhcp.leases`; Android private MAC may create a different identity. |

## Documentation

- `AGENTS.md`: AI handoff rules
- `PRD.md`: behavior and acceptance criteria
- `TECHNICAL-DESIGN.md`: architecture and invariants
- `ROADMAP.md`: shipped work and next work
- `PLAN.md`: original feature plan; update or replace when scope changes

## Release

Push `main` for CI artifact. Push a tag `vX.Y.Z` to create a GitHub release.

```sh
git tag -a v1.0.2 -m 'Bandwidth Control 1.0.2'
git push origin v1.0.2
```
