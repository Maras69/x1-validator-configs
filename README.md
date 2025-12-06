# X1 Validator Configs - Marask Fleet

Configuration files for 7 X1 validators.

## Servers
| Server | IP | Location |
|--------|-----|----------|
| marask1 | 74.50.94.66 | USA |
| marask2 | 178.63.249.71 | Germany |
| marask3 | 205.209.113.166 | USA |
| marask4 | 149.50.108.124 | Poland |
| marask5 | 65.21.12.56 | Germany |
| marask6 | 149.50.110.19 | Poland |
| marask7 | 149.50.108.142 | Poland |

## Contents per server
- `tachyon-validator.service` - systemd service file
- `fstab` - mount configuration (tmpfs for accounts)
- `monthly-maintenance.timer` - maintenance schedule
- `monthly-maintenance.service` - maintenance service
- `update_upgrade_clean.sh` - update script
- `snapshot-cleanup` - daily snapshot cleanup cron
- `tachyon-validator` - logrotate config (if applicable)
