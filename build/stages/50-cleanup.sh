#!/usr/bin/env bash
# Stage 50 — shrink the chroot: clear apt caches, logs, machine-id, temp files.
# A smaller chroot = a smaller squashfs = a smaller ISO.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${HERE}/config.sh"
source "${HERE}/lib.sh"

require_root
[[ -d "${CHROOT_DIR}/usr/bin" ]] || die "no chroot — run earlier stages first"

mount_chroot "${CHROOT_DIR}"
trap 'umount_chroot "${CHROOT_DIR}"' EXIT

log "apt autoremove + clean"
chroot_exec "${CHROOT_DIR}" apt-get autoremove -y || true
chroot_exec "${CHROOT_DIR}" apt-get clean

log "removing build artefacts and caches"
rm -rf "${CHROOT_DIR}/tmp/dyuti-build" "${CHROOT_DIR}/tmp/"*.deb
rm -rf "${CHROOT_DIR}/var/lib/apt/lists/"*
rm -rf "${CHROOT_DIR}/var/cache/apt/archives/"*.deb
rm -rf "${CHROOT_DIR}/var/log/"*.log "${CHROOT_DIR}/var/log/"*/*.log 2>/dev/null || true

# Live images must NOT ship a fixed machine-id (it is generated on first boot).
: > "${CHROOT_DIR}/etc/machine-id"
rm -f "${CHROOT_DIR}/var/lib/dbus/machine-id"

# resolv.conf was copied for build-time networking; let the live system manage it.
rm -f "${CHROOT_DIR}/etc/resolv.conf"

# Drop bash history if any.
rm -f "${CHROOT_DIR}/root/.bash_history"

ok "chroot cleaned"
