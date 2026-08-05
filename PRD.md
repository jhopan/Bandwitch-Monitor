# Product Requirements Document

## Product

Bandwidth Control is a self-hosted OpenWrt LuCI package that tracks data use per client MAC or MAC group and blocks internet traffic when a quota is reached.

## Problem

Small hotspot/LAN operators need a lightweight local quota system. Existing counters are hard to map to devices, reset safely, and enforce through firewall rules.

## Target users

- OpenWrt router/STB owner
- Admin managing WiFi and LAN clients
- No cloud account or external backend required

## Current user goals

1. Select connected clients from DHCP leases.
2. Give a client a decimal GB quota, e.g. `0.1`, `0,5`, `2`.
3. See usage, RX/TX, hostname/IP history, and status.
4. Auto-block internet when quota is used.
5. Unblock or reset a quota manually.
6. Create a static DHCP lease.
7. Back up and restore package data.

## Functional requirements

### Device quotas

- Device identity is MAC address.
- Usage equals nlbwmon RX + TX after device baseline.
- Decimal quota input accepts comma or dot.
- `Reset now` starts a new baseline and clears a quota-caused block.
- Manual block remains blocked after reset.

### Group quotas

- Group stores multiple MAC addresses.
- Member usage is summed.
- Reaching group quota blocks all group members.

### Enforcement

- nftables set stores blocked source MACs.
- Block hook executes before fw4 LAN-to-WAN accept rules.
- Block reason is one of `quota`, `quota-group`, or `manual`.
- Audit records reset, block, and unblock events.

### LuCI

- DHCP lease picker lists active leases.
- Device table shows quota, reset policy, usage, down/up, last seen, status, and controls.
- Page refreshes usage every 30 seconds only when form is not being edited.
- Backup exports UCI config and package runtime state.
- Restore accepts only expected package paths.

## Non-functional requirements

- Works offline after package installation.
- Low resource use: POSIX shell, UCI, nftables, existing nlbwmon.
- Architecture-independent main IPK.
- Preserve administrator UCI config during ordinary IPK upgrade.
- Do not break normal fw4 forwarding for allowed users.

## Acceptance criteria

- With quota `0.1 GB`, a client generating >102.4 MB after baseline is blocked within two worker cycles.
- Allowed client still accesses internet before quota.
- Reset returns usage to zero and restores a quota-blocked client.
- Manual block survives Reset.
- Client behind STB WiFi, LAN cable, or LAN-to-LAN AP bridge is counted, provided traffic routes through STB.
- Existing configured devices persist through ordinary versioned package upgrade.

## Out of scope

- Speed limiting (`tc`/CAKE)
- Captive portal redirect
- Voucher/payment system
- Cloud synchronization
- Multi-router centralized control

See `ROADMAP.md` for future work.