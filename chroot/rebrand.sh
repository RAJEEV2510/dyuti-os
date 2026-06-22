#!/usr/bin/env bash
# Runs INSIDE the chroot. Strips every user-visible Ubuntu/KDE mark so the system
# presents only as Dyuti. (Required by upstream trademark policy when remixing;
# licenses are still honoured — this is branding, not code removal.)

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
say() { echo "  [chroot] $*"; }

DISTRO_NAME="${DISTRO_NAME:-Dyuti}"

# --- lsb-release (what `lsb_release` and many tools report) -------------------
say "rewriting /etc/lsb-release"
cat > /etc/lsb-release <<EOF
DISTRIB_ID=${DISTRO_NAME}
DISTRIB_RELEASE=0.1
DISTRIB_CODENAME=prabha
DISTRIB_DESCRIPTION="${DISTRO_NAME} OS 0.1"
EOF

# --- console login banners ---------------------------------------------------
say "rewriting issue / motd"
printf '%s OS \\n \\l\n\n' "${DISTRO_NAME}" > /etc/issue
printf '%s OS\n' "${DISTRO_NAME}" > /etc/issue.net
: > /etc/motd

# --- kill Ubuntu's dynamic MOTD ("Welcome to Ubuntu", news, ads) -------------
if [ -d /etc/update-motd.d ]; then
  say "disabling Ubuntu dynamic MOTD scripts"
  chmod -x /etc/update-motd.d/* 2>/dev/null || true
fi
if [ -f /etc/default/motd-news ]; then
  sed -i 's/^ENABLED=1/ENABLED=0/' /etc/default/motd-news || true
fi
systemctl disable motd-news.timer 2>/dev/null || true

# --- live session identity (casper defaults to a user named "ubuntu") --------
say "writing /etc/casper.conf"
LIVE_USER="$(echo "${DISTRO_NAME}" | tr '[:upper:]' '[:lower:]')"
cat > /etc/casper.conf <<EOF
export USERNAME="${LIVE_USER}"
export USERFULLNAME="${DISTRO_NAME} Live Session"
export HOST="${LIVE_USER}"
export BUILD_SYSTEM="${DISTRO_NAME}"
export FLAVOUR="${DISTRO_NAME}"
EOF

# --- GRUB distributor (the name shown by an installed system's bootloader) ----
if [ -f /etc/default/grub ]; then
  say "setting GRUB distributor"
  if grep -q '^GRUB_DISTRIBUTOR=' /etc/default/grub; then
    sed -i "s/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR=\"${DISTRO_NAME} OS\"/" /etc/default/grub
  else
    echo "GRUB_DISTRIBUTOR=\"${DISTRO_NAME} OS\"" >> /etc/default/grub
  fi
fi

# --- purge Ubuntu-branded fluff (best-effort; minbase has little anyway) ------
say "purging Ubuntu branding packages (best-effort)"
for p in \
    ubuntu-wallpapers ubuntu-wallpapers-noble \
    plymouth-theme-ubuntu-text plymouth-theme-ubuntu-logo \
    ubuntu-docs example-content ubuntu-release-upgrader-core \
    ; do
  apt-get purge -y "$p" 2>/dev/null || true
done

say "rebrand pass complete"
