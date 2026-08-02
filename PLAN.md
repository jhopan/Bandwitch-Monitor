# Bandwidth Control 1–8 Plan

Goal: Add quota period controls, status dashboard, warnings, manual block state, static DHCP lease action, device details, and clean defaults without speed limiting.

Scope:
1. `nlbwmon` remains accounting source. Reset setting changes its `database_interval` (day of month).
2. Enforcement stays MAC-based through nftables. IP only identifies a lease.
3. `/etc/bandwidth-control/<mac>.reason` persists `quota` or `manual`; `.blocked` persists block state.
4. Automatic checks never unblock. Only manual Unblock clears state. This prevents quota checks from undoing manual blocks.
5. LuCI dashboard displays used, quota, remaining, percent, RX/TX, state, reason, last action.
6. DHCP static lease action writes UCI host section from current lease MAC/IP/hostname, then reloads dnsmasq.
7. No default sample devices/groups.
8. No rate limit. `tc`/CAKE is later work.

Verification:
- Shell tests: quota counting, DHCP parsing, block-state persistence.
- STB: Lua syntax, service state, nft table, UCI config, static lease generation.
- Browser: add DHCP device, block/unblock, static lease action, dashboard refresh.

Risk: changing nlbwmon period starts new accounting DB according to nlbwmon behavior. UI must state reset takes effect for next nlbwmon period; it cannot rewrite existing counters.
