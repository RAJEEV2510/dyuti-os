#!/usr/bin/env bash
# Runs INSIDE the chroot. System-level defaults that make the live image behave:
# display manager, autologin for the live session, services, smoothness tweaks.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
say() { echo "  [chroot] $*"; }

# --- display manager: SDDM is the natural fit for Plasma ----------------------
say "setting SDDM as the display manager"
# Must be the real sddm binary path: sddm.service has an ExecStartPre guard that
# refuses to start unless this file reads exactly "/usr/bin/sddm". Writing the
# wrong path (/usr/sbin/sddm) makes sddm.service fail and the desktop never
# appears — the live session boots to a black console instead.
echo "/usr/bin/sddm" > /etc/X11/default-display-manager || true
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
# Chrome/Chromium/Electron need unprivileged user namespaces for their sandbox.
# Ubuntu 24.04 restricts them by default (apparmor_restrict_unprivileged_userns=1),
# so Chrome crashes on launch ("Check failed ... Permission denied" /
# Trace/breakpoint trap). Re-enable them so the browser sandbox works.
kernel.apparmor_restrict_unprivileged_userns=0
EOF

# --- NetworkManager: actually manage the wired device ------------------------
# On a minimal Ubuntu base, NM ships a default that leaves ethernet "unmanaged"
# (it expects netplan/networkd to own it). With no netplan config either, the
# live + installed system boot with NO network — `nmcli device` shows the wired
# NIC as "unmanaged" and connectivity "none". Make NM manage every device, and
# point netplan at NM (the Ubuntu-desktop default), so wired + Wi-Fi auto-connect.
say "configuring NetworkManager to manage all network devices"
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/99-dyuti-manage-all.conf <<'NMCONF'
[main]
# Write /etc/resolv.conf directly. The minimal base ships systemd-resolved
# installed but disabled, and cleanup removes resolv.conf, so without this NM
# has nowhere to put DNS — name resolution (Chrome, apt, getent) fails even
# though the link is up and `nmcli` reports "full". dns=default makes NM
# populate /etc/resolv.conf itself from the active connection's DNS servers.
dns=default

[keyfile]
unmanaged-devices=
NMCONF
mkdir -p /etc/netplan
cat > /etc/netplan/01-network-manager-all.yaml <<'NETPLAN'
network:
  version: 2
  renderer: NetworkManager
NETPLAN
chmod 600 /etc/netplan/01-network-manager-all.yaml

# --- live boot: make casper's overlay setup actually work ---------------------
# Symptom: the live image dropped to a BusyBox initramfs shell with
#   "/cow format specified as 'overlay' and no support found".
#
# Root cause (verified by extracting casper out of the built initrd): casper
# creates the writable /cow layer with this line —
#       modprobe "${MP_QUIET}" -b overlay || panic "/cow format specified ..."
# MP_QUIET is meant to be "-q" but is never set in our initramfs, so it expands
# to an EMPTY argument and the call actually runs `modprobe "" -b overlay`. An
# empty module name always fails ("modprobe: FATAL: Module  not found"), so
# casper panics even though overlay is present and perfectly loadable. The bug
# is a malformed command, NOT a missing module — which is why simply forcing the
# modules in or pre-loading overlay never fixed it.
#
# Fix it two independent ways so it cannot regress:
#   1) define MP_QUIET=-q via a conf.d snippet. casper sources /conf/conf.d/*
#      before the overlay line, so the call becomes a well-formed
#      `modprobe -q -b overlay`. (This also repairs the same latent bug on
#      casper's nfs / isofs / cifs / af_packet modprobe lines.)
#   2) drop the quotes around ${MP_QUIET} in the casper script itself, so an
#      empty value just disappears instead of becoming a bogus "" argument.
# We still list overlay/squashfs/loop so they are guaranteed to be in the image.
say "fixing casper overlay setup (MP_QUIET) and ensuring union modules present"

# (1) well-formed modprobe via MP_QUIET, baked into the initramfs.
mkdir -p /etc/initramfs-tools/conf.d
echo 'MP_QUIET=-q' > /etc/initramfs-tools/conf.d/dyuti-mpquiet

# Ensure the union/live modules are in the image.
for m in overlay squashfs loop; do
  grep -qxF "$m" /etc/initramfs-tools/modules 2>/dev/null || echo "$m" >> /etc/initramfs-tools/modules
done

# Drop the stale premount hack from earlier debugging if it's lingering.
rm -f /etc/initramfs-tools/scripts/init-premount/dyuti-load-overlay

# (2) patch the casper boot script so every modprobe tolerates an empty MP_QUIET.
CASPER=/usr/share/initramfs-tools/scripts/casper
if [ -f "$CASPER" ]; then
  sed -i 's/modprobe "${MP_QUIET}"/modprobe ${MP_QUIET}/g' "$CASPER"
fi

# Rebuild the initramfs so the conf.d snippet + patched casper are baked in.
# Critical for a bootable live image, so let a failure stop the build.
say "updating initramfs"
update-initramfs -u

# Verify the fix actually landed in the freshly built initrd — fail the build if
# the broken quoted modprobe line is still present, so we never boot a stale or
# unpatched image again.
say "verifying the overlay fix is in the initramfs"
_img="$(ls -1 /boot/initrd.img-* 2>/dev/null | sort -V | tail -n1)"
if [ -n "${_img}" ] && command -v unmkinitramfs >/dev/null 2>&1; then
  _t="$(mktemp -d)"
  unmkinitramfs "${_img}" "${_t}" 2>/dev/null || true
  _r="${_t}"; [ -d "${_t}/main" ] && _r="${_t}/main"
  if [ -f "${_r}/scripts/casper" ]; then
    if grep -q 'modprobe "${MP_QUIET}" -b overlay' "${_r}/scripts/casper"; then
      echo "  [chroot] ERROR: initrd casper still has the broken quoted overlay modprobe" >&2
      rm -rf "${_t}"; exit 1
    fi
    say "overlay fix verified — casper modprobe line in the initrd is well-formed"
  else
    say "WARN: casper not found in unpacked initrd; skipping verification"
  fi
  rm -rf "${_t}"
else
  say "WARN: cannot unpack initrd to verify (continuing)"
fi

say "system configuration finished"
