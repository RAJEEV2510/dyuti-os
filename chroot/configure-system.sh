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

# --- live boot needs the union/overlay stack in the initramfs -----------------
# casper mounts the read-only squashfs and layers a writable overlay (/cow) on
# top. If these modules aren't in the initramfs, the live session aborts to a
# busybox shell with "/cow format specified as 'overlay' and no support found".
# Force them in so the live boot always finds overlay (+ squashfs + loop).
say "ensuring live-boot modules (overlay, squashfs, loop) are in the initramfs"
mkdir -p /etc/initramfs-tools
for m in overlay squashfs loop; do
  grep -qxF "$m" /etc/initramfs-tools/modules 2>/dev/null || echo "$m" >> /etc/initramfs-tools/modules
done

# Update the initramfs so casper hooks + the modules above are picked up.
# This is critical for a bootable live image, so let a failure stop the build.
say "updating initramfs"
update-initramfs -u

say "system configuration finished"
