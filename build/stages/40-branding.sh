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
# lose the bit; dpkg needs maintainer scripts executable and tools runnable).
for s in preinst postinst postrm; do
  [[ -f "${PKG_SRC}/DEBIAN/${s}" ]] && chmod 0755 "${PKG_SRC}/DEBIAN/${s}" || true
done
if [[ -d "${PKG_SRC}/usr/bin" ]]; then
  chmod 0755 "${PKG_SRC}/usr/bin/"* 2>/dev/null || true
fi

# Template our os-release under a NON-conflicting name. /usr/lib/os-release is
# owned by base-files, so we cannot ship that path directly (dpkg refuses). The
# package's preinst dpkg-diverts it and the postinst symlinks ours in.
log "templating os-release (os-release.dyuti)"
mkdir -p "${PKG_SRC}/usr/lib"
cat > "${PKG_SRC}/usr/lib/os-release.dyuti" <<EOF
PRETTY_NAME="${DISTRO_NAME} ${DISTRO_VERSION}"
NAME="${DISTRO_NAME}"
VERSION_ID="${DISTRO_VERSION}"
VERSION="${DISTRO_VERSION} (${DISTRO_CODENAME})"
VERSION_CODENAME=${DISTRO_CODENAME}
ID=${DISTRO_ID}
ID_LIKE="debian"
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
# Use dpkg -i, not `apt-get install`: the package version is a constant (0.1),
# so apt sees "already newest" on every rebuild and SKIPS reinstalling — the
# old files (e.g. widgetStyle=Breeze) would survive. dpkg -i always unpacks the
# given .deb regardless of version; apt-get -f repairs any missing deps after.
chroot_exec "${CHROOT_DIR}" dpkg -i "/tmp/$(basename "${DEB_OUT}")" \
  || chroot_exec "${CHROOT_DIR}" apt-get -f install -y
# /etc/os-release is a base-files symlink to ../usr/lib/os-release, which our
# preinst diverts and postinst repoints to os-release.dyuti — nothing more to do.

# Verify the rebrand actually took effect inside the chroot.
log "verifying os-release"
chroot_exec "${CHROOT_DIR}" head -3 /usr/lib/os-release || warn "could not read os-release"

ok "branding applied"
