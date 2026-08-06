# Technical Design

## Architecture

```text
Client MAC
  └─ STB WiFi / LAN / LAN-to-LAN AP bridge
       └─ br-lan
           └─ STB routing → WAN
                ├─ nlbwmon reads conntrack counters
                ├─ bandwidth-control/check computes raw - baseline
                └─ nftables drops blocked source MAC before fw4 accept

LuCI CBI → UCI config + check commands → state files
```

## Components

| Component | Path | Role |
|---|---|---|
| Quota engine | `files/usr/libexec/bandwidth-control/check` | Usage, baseline, state, audit, nftables, quota check |
| Service | `files/etc/init.d/bandwidth-control` | procd loop; default 60 second check |
| UCI config | `files/etc/config/bandwidth-control` | Service, device, group settings |
| LuCI | `luci/model/cbi/bandwidth_control.lua` | Admin UI and actions |
| LuCI styles | `luci/view/bandwidth_control/styles.htm` | scrollable table and safe auto-refresh |
| Package metadata | `CONTROL/` | dependency, conffile, postinstall |

## Data model

### UCI

```text
config main
  option enabled '1'
  option interval '60'
  option reset_day '1'

config device
  option name 'Client name'
  option mac 'aa:bb:cc:dd:ee:ff'
  option quota_gb '0.1'
  option rolling_days '0'
  option enabled '1'

config group
  option name 'Family'
  option quota_gb '10'
  list mac '...'
```

### Runtime state

`/etc/bandwidth-control/<mac>.*`

| File | Meaning |
|---|---|
| `.baseline` | nlbwmon RX/TX/total at reset |
| `.last_raw` | last raw nlbwmon RX/TX/total seen by quota engine |
| `.used` | persistent RX/TX/total accumulated since reset; survives nlbwmon restart |
| `.reset_at` | epoch reset timestamp |
| `.blocked` | blocked marker |
| `.reason` | `quota`, `quota-group`, `manual` |
| `.at` | block timestamp |
| `.last_seen`, `.host`, `.ip` | DHCP-derived client history |
| `audit.log` | last 200 events |

## Accounting

`nlbw -c csv -g mac -o mac -q` provides raw RX/TX. The engine computes:

```text
delta_rx = raw_rx - last_raw_rx
delta_tx = raw_tx - last_raw_tx
if delta becomes negative: use current raw counter after nlbwmon restart/period rollover
used_rx += delta_rx
used_tx += delta_tx
used_total = used_rx + used_tx
```

`.used` and `.last_raw` persist on disk. All persisted arithmetic uses `awk` decimal numbers rather than shell integer arithmetic, so counters can exceed 2 GiB and support terabyte-scale quotas. Restarting `nlbwmon`, `bandwidth-control`, or router does not reset quota usage. Only Reset now creates a new zero baseline.

## Enforcement

```nft
table inet bandwidth_control {
  set blocked_macs { type ether_addr; flags interval; }
  chain forward {
    type filter hook forward priority filter - 1; policy accept;
    ether saddr @blocked_macs drop
  }
}
```

Priority `filter - 1` is mandatory. fw4 accepts LAN-to-WAN at priority `filter`; later drop rules do not work.

## Update safety

`CONTROL/conffiles` includes `/etc/config/bandwidth-control`. Ordinary `opkg install` merges/preserves administrator config. Do not rely on `--force-reinstall` for normal updates. Runtime state is generated outside IPK payload.

## UI refresh safety

Auto refresh runs every 30 seconds if no field has changed. It navigates to main path, not `reload()`, because reload can replay an action endpoint such as Reset.

## Dependencies

- `nlbwmon`: architecture/release specific
- `nftables-json`
- `luci-base`
- `luci-compat`
- OpenWrt fw4/nftables

## Security notes

- Restore validates archive paths before extraction.
- Shell invocations from LuCI quote MAC/IP inputs.
- MAC validation uses strict six-byte format.
- Backup/restore is admin-only through LuCI authentication.