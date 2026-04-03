# X1 Validator Configs - Marask Fleet

Configuration files for 7 X1 validators running tachyon v2.2.20.

## Servers

| Server | Validator | IP | ISP | Location |
|--------|-----------|-----|-----|----------|
| marask1 | X1 Legion | 74.50.94.66 | Interserver | USA |
| marask2 | XENLPN | 45.131.114.130 | Servernet | NL |
| marask3 | Junior | 205.209.113.166 | Interserver | USA |
| marask4 | Marask 4 | 45.131.114.66 | Servernet | NL |
| marask5 | Marask 5 | 45.131.114.138 | Servernet | NL |
| marask6 | Marask 6 | 45.131.114.146 | Servernet | NL |
| marask7 | Marask 7 | 45.131.114.74 | Servernet | NL |

## Current State (Apr 3, 2026)
- Version: v2.2.20
- Dynamic port range: 8000-10000
- UFW: 8000-10000 TCP+UDP open
- All validators: 0 skip rate, 99.31% network block production

## Contents per server
- `tachyon-validator.service` - systemd service file
- `fstab` - mount configuration
- `monthly-maintenance.timer` - maintenance schedule (where applicable)
- `monthly-maintenance.service` - maintenance service (where applicable)
- `update_upgrade_clean.sh` - update script (where applicable)
- `snapshot-cleanup` - daily snapshot cleanup cron (where applicable)
- `tachyon-validator` - logrotate config (where applicable)

## Key Configuration Notes
- SSH port: 8822 on all servers
- Entrypoints: entrypoint1-4.mainnet.x1.xyz:8001
- Accounts stored in tmpfs (/run/accounts) for performance
- UFW firewall: 8000-10000 TCP+UDP required for full validator communication
