#!/usr/bin/env bash
# Runs INSIDE the chroot. System-level defaults that make the live image behave:
# display manager, autologin for the live session, services, smoothness tweaks.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
say() { echo "  [chroot] $*"; }

# --- display manager: SDDM is the natural fit for Plasma ----------------------
say "setting SDDM as the display manager"
echo "/usr/sbin/sddm" > /etc/X11/default-display-manager || true
echo "set shared/default-x-display-manager sddm" | debconf-communicate >/dev/null 2>&1 || true

# --- live session user --------------------------------------------------------
# casper creates the live user at boot; we just make sure the group + sudo exist.
say "ensuring sudo present"
apt-get install -y --no-install-recommends sudo

# --- default target = graphical ----------------------------------------------
ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target

# --- smoothness / footprint tweaks -------------------------------------------
say "applying smoothness defaults"
# Prefer responsiveness on the desktop.
mkdir -p /etc/sysctl.d
cat > /etc/sysctl.d/99-dyuti-desktop.conf <<'EOF'
vm.swappiness=10
EOF

# Update the initramfs so casper hooks are picked up.
say "updating initramfs"
update-initramfs -u || true

say "system configuration finished"
