#!/usr/bin/env bash
# Stage 40 — build the branding .deb from source and install it into the chroot.
# Branding = os-release, wallpaper, Plasma defaults, Calamares look.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${HERE}/config.sh"
source "${HERE}/lib.sh"

require_root
require_cmd dpkg-deb
[[ -d "${CHROOT_DIR}/usr/bin" ]] || die "no chroot — run earlier stages first"

PKG_SRC="${BRANDING_DIR}/${DISTRO_ID}-branding"
[[ -d "${PKG_SRC}/DEBIAN" ]] || die "branding package source missing: ${PKG_SRC}"

# Ensure maintainer scripts and shipped executables are +x (Windows checkouts
# lose the bit; dpkg needs postinst executable and /usr/bin tools runnable).
chmod 0755 "${PKG_SRC}/DEBIAN/postinst" 2>/dev/null || true
if [[ -d "${PKG_SRC}/usr/bin" ]]; then
  chmod 0755 "${PKG_SRC}/usr/bin/"* 2>/dev/null || true
fi

# Template the os-release with the current brand/version before packaging.
log "templating os-release"
mkdir -p "${PKG_SRC}/usr/lib"
cat > "${PKG_SRC}/usr/lib/os-release" <<EOF
PRETTY_NAME="${DISTRO_NAME} ${DISTRO_VERSION}"
NAME="${DISTRO_NAME}"
VERSION_ID="${DISTRO_VERSION}"
VERSION="${DISTRO_VERSION} (${DISTRO_CODENAME})"
VERSION_CODENAME=${DISTRO_CODENAME}
ID=${DISTRO_ID}
ID_LIKE="ubuntu debian"
HOME_URL="${DISTRO_URL}"
SUPPORT_URL="${DISTRO_URL}"
BUG_REPORT_URL="${DISTRO_URL}"
LOGO=dyuti-logo
ANSI_COLOR="0;38;2;255;157;77"
EOF

# Build the .deb into the work dir.
mkdir -p "${WORK_DIR}/pkgs"
DEB_OUT="${WORK_DIR}/pkgs/${DISTRO_ID}-branding.deb"
log "building branding package → ${DEB_OUT}"
dpkg-deb --root-owner-group --build "${PKG_SRC}" "${DEB_OUT}"

# Install it inside the chroot.
mount_chroot "${CHROOT_DIR}"
trap 'umount_chroot "${CHROOT_DIR}"' EXIT

cp "${DEB_OUT}" "${CHROOT_DIR}/tmp/"
log "installing branding package inside chroot"
chroot_exec "${CHROOT_DIR}" apt-get install -y "/tmp/$(basename "${DEB_OUT}")"
# os-release lives in /usr/lib; make sure /etc/os-release points at it.
chroot_exec "${CHROOT_DIR}" ln -sf ../usr/lib/os-release /etc/os-release

ok "branding applied"
