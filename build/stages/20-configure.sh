#!/usr/bin/env bash
# Stage 20 — apt sources, hostname, locales; mount virtual filesystems.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${HERE}/config.sh"
source "${HERE}/lib.sh"

require_root
[[ -d "${CHROOT_DIR}/usr/bin" ]] || die "no chroot — run stage 10-bootstrap first"

# --- apt sources (full Ubuntu archive: base + security + updates) -------------
log "writing apt sources"
cat > "${CHROOT_DIR}/etc/apt/sources.list" <<EOF
deb ${BASE_MIRROR} ${BASE_SUITE} ${BASE_COMPONENTS//,/ }
deb ${BASE_MIRROR} ${BASE_SUITE}-updates ${BASE_COMPONENTS//,/ }
deb ${BASE_MIRROR} ${BASE_SUITE}-backports ${BASE_COMPONENTS//,/ }
deb http://security.ubuntu.com/ubuntu ${BASE_SUITE}-security ${BASE_COMPONENTS//,/ }
EOF

# --- identity files ------------------------------------------------------------
echo "${DISTRO_ID}" > "${CHROOT_DIR}/etc/hostname"
cat > "${CHROOT_DIR}/etc/hosts" <<EOF
127.0.0.1   localhost
127.0.1.1   ${DISTRO_ID}
::1         localhost ip6-localhost ip6-loopback
EOF

# --- mount + refresh apt -------------------------------------------------------
mount_chroot "${CHROOT_DIR}"
trap 'umount_chroot "${CHROOT_DIR}"' EXIT

log "apt update inside chroot"
chroot_exec "${CHROOT_DIR}" apt-get update

# --- locales -------------------------------------------------------------------
log "generating locales: ${SHIP_LOCALES}"
for loc in ${SHIP_LOCALES}; do
  echo "${loc}.UTF-8 UTF-8" >> "${CHROOT_DIR}/etc/locale.gen"
done
chroot_exec "${CHROOT_DIR}" locale-gen
echo "LANG=${DEFAULT_LOCALE}" > "${CHROOT_DIR}/etc/default/locale"

ok "chroot configured"
