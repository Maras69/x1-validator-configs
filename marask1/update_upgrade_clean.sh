#!/bin/bash
# Single monthly system update & cleanup for Marask X1 Legion
set -euo pipefail
PATH=/usr/sbin:/usr/bin:/sbin:/bin
SERVICE="tachyon-validator"

log(){ echo "[$(date '+%F %T %Z')] $*"; }

log "=== Starting monthly update/upgrade/clean ==="
export DEBIAN_FRONTEND=noninteractive
APT_FLAGS=(-y -o Dpkg::Options::=--force-confnew -o Acquire::Retries=3)

apt-get update
apt-get "${APT_FLAGS[@]}" full-upgrade
apt-get "${APT_FLAGS[@]}" autoremove --purge
apt-get -y autoclean
apt-get -y clean

if command -v snap >/dev/null 2>&1; then
  snap refresh || true
  snap set system refresh.retain=2 || true
  snap list --all | awk '/disabled/{print $1, $3}' | while read -r n r; do
    snap remove "$n" --revision="$r" || true
  done
fi

if command -v journalctl >/dev/null 2>&1; then
  journalctl --vacuum-time=7d || true
  journalctl --vacuum-size=1G || true
fi

systemctl daemon-reload || true
systemctl restart "$SERVICE" || true

log "=== Monthly maintenance completed ==="
