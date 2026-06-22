#!/usr/bin/env bash
# Stage 30 — install kernel, live-boot bits, KDE Plasma, apps, languages,
# and the Calamares installer. Heavy lifting runs INSIDE the chroot.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${HERE}/config.sh"
source "${HERE}/lib.sh"

require_root
[[ -d "${CHROOT_DIR}/usr/bin" ]] || die "no chroot — run stages 10 and 20 first"

mount_chroot "${CHROOT_DIR}"
trap 'umount_chroot "${CHROOT_DIR}"' EXIT

# Copy the in-chroot scripts and package lists into the chroot so they can run there.
log "staging in-chroot scripts + package lists"
mkdir -p "${CHROOT_DIR}/tmp/dyuti-build/lists"
cp "${CHROOT_SCRIPTS}"/*.sh                "${CHROOT_DIR}/tmp/dyuti-build/"
cp "${CONFIG_DIR}/package-lists/"*.list    "${CHROOT_DIR}/tmp/dyuti-build/lists/"
chmod +x "${CHROOT_DIR}/tmp/dyuti-build/"*.sh

# Pass selected config through to the chroot scripts via the environment.
log "running install-desktop.sh inside chroot (this takes a while)"
chroot_exec "${CHROOT_DIR}" \
  env DISTRO_NAME="${DISTRO_NAME}" DISTRO_ID="${DISTRO_ID}" \
      SHIP_LOCALES="${SHIP_LOCALES}" DEFAULT_LOCALE="${DEFAULT_LOCALE}" \
  bash /tmp/dyuti-build/install-desktop.sh

ok "desktop, apps, languages and installer present in chroot"
