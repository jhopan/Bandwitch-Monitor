# Roadmap

## Shipped

- [x] IPK packaging and OpenWrt 24.10 armsr/armv8 validation
- [x] Per-MAC quota using decimal GB input
- [x] Group quota
- [x] nlbwmon RX + TX accounting
- [x] Baseline reset per device
- [x] Manual block, quota block, unblock, audit state
- [x] nftables enforcement before fw4 forwarding accept
- [x] DHCP lease picker and static lease action
- [x] Last seen IP/hostname history
- [x] Backup/restore with path restriction
- [x] Config preservation on ordinary package upgrade
- [x] Safe LuCI auto-refresh
- [x] Live quota enforcement verified through LAN-to-LAN AP bridge
- [x] GitHub Actions IPK artifacts and tagged release flow

## Next: reliability

- [ ] Replace LuCI page reload with lightweight status endpoint / polling.
- [ ] Add exact human-readable remaining quota and colored warning badges.
- [ ] Add visible block reason and timestamp card.
- [ ] Add device-card UI instead of wide action table.
- [ ] Add automated target-side smoke test script.
- [ ] Verify config upgrade preservation on a test router without `--force-reinstall`.

## Future: policy

- [ ] Quota warning at 80% and 95%.
- [ ] Scheduled reset policy beyond 7/30 days.
- [ ] Optional Telegram/admin notification.
- [ ] Group usage/status display.
- [ ] Export audit log as CSV.

## Future: traffic control

- [ ] Optional per-device down/up shaping with `tc`/CAKE.
- [ ] Keep speed shaping independent from quota enforcement.
- [ ] Measure impact on low-resource OpenWrt targets.

## Not planned now

- Payment
- Voucher generator
- Captive portal redirect
- Central cloud service
- Multi-router synchronization

## Versioning

Bump `CONTROL/control` version for every published/installable update. Tag releases as `vX.Y.Z` after a tested versioned commit.