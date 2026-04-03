#!/bin/bash
# update_upgrade_clean.sh — Ubuntu update, upgrade, and cleanup
# Minimal downtime: download first, stop validator only for install.
set -euo pipefail
IFS=$'\n\t'
PATH=/usr/sbin:/usr/bin:/sbin:/bin

SERVICE="tachyon-validator"
REBOOT_FLAG="/var/run/reboot-required"

log(){ echo "[$(date '+%F %T %Z')] $*"; }
need_reboot(){ [[ -f "$REBOOT_FLAG" ]]; }

# Ensure root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo $0)"; exit 1
fi

# Avoid interactive prompts
export DEBIAN_FRONTEND=noninteractive
APT_FLAGS=(-y -o Dpkg::Options::=--force-confnew -o Acquire::Retries=3)

# Wait for apt/dpkg locks (up to ~5 min)
for i in {1..60}; do
  if fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; then
    [[ $i -eq 1 ]] && log "Waiting for other apt/dpkg to finish..."
    sleep 5
  else
    break
  fi
done

log "=== apt update ==="
apt-get update

log "=== Pre-download upgrades (no changes yet) ==="
apt-get "${APT_FLAGS[@]}" -d full-upgrade

log "=== Stop $SERVICE for install phase ==="
if systemctl is-active --quiet "$SERVICE"; then
  systemctl stop "$SERVICE"
else
  log "$SERVICE already stopped."
fi

log "=== apt full-upgrade (install) ==="
apt-get "${APT_FLAGS[@]}" full-upgrade

log "=== apt autoremove & cleanup ==="
apt-get "${APT_FLAGS[@]}" autoremove --purge
apt-get -y autoclean
apt-get -y clean

# Snap cleanup (keep only latest 2 revs; remove disabled)
if command -v snap >/dev/null 2>&1; then
  log "=== snap refresh (if updates) ==="
  snap refresh || true
  log "=== snap cleanup (keep 2) ==="
  snap set system refresh.retain=2 || true
  snap list --all | awk '/disabled/{print $1, $3}' | while read -r name rev; do
    snap remove "$name" --revision="$rev" || true
  done
fi

# Journal cleanup: keep 7 days OR max 1G (whichever hits first)
if command -v journalctl >/dev/null 2>&1; then
  log "=== journald vacuum (7d / 1G) ==="
  journalctl --vacuum-time=7d || true
  journalctl --vacuum-size=1G || true
fi

# Reload systemd units (harmless if nothing changed)
systemctl daemon-reload || true

log "=== Restart $SERVICE ==="
systemctl restart "$SERVICE" || true
if systemctl is-active --quiet "$SERVICE"; then
  log "$SERVICE is running."
else
  log "WARN: $SERVICE failed to start; check 'journalctl -u $SERVICE -e'."
fi

if need_reboot; then
  log "=== Reboot recommended (kernel/glibc/etc updated). ==="
  log "Run 'sudo reboot' when convenient."
else
  log "=== Done (no reboot required) ==="
fi
