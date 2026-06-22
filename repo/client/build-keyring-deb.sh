#!/usr/bin/env bash
# Build the dyuti-archive-keyring .deb that clients install so they trust and
# pull updates from the Dyuti repo. Bundle this .deb into the ISO (config the
# build to install it) so every Dyuti system updates from your infra.
#
# Prereq: run ../setup-repo.sh first (it exports the public key into ../keys/).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${HERE}/../config.sh"

KEY_GPG="${KEYS_DIR}/dyuti-archive-keyring.gpg"
[[ -f "${KEY_GPG}" ]] || { echo "missing ${KEY_GPG} — run setup-repo.sh first"; exit 1; }
command -v dpkg-deb >/dev/null || { echo "need dpkg-deb"; exit 1; }

OUT_DIR="${HERE}/out"
PKG="${OUT_DIR}/dyuti-archive-keyring"
rm -rf "${PKG}"
mkdir -p "${PKG}/DEBIAN" \
         "${PKG}/usr/share/keyrings" \
         "${PKG}/etc/apt/sources.list.d"

# control
cat > "${PKG}/DEBIAN/control" <<EOF
Package: dyuti-archive-keyring
Version: 0.1
Architecture: all
Maintainer: Dyuti Project <${GPG_EMAIL}>
Section: misc
Priority: optional
Description: Dyuti OS archive keyring and update source
 Installs the Dyuti archive signing key and APT source so the system can
 receive signed updates from the Dyuti repository.
EOF

# the trusted key
cp "${KEY_GPG}" "${PKG}/usr/share/keyrings/dyuti-archive-keyring.gpg"

# the source, with the real public URL substituted in
sed "s|__REPO_PUBLIC_URL__|${REPO_PUBLIC_URL}|g" \
  "${HERE}/dyuti.sources" > "${PKG}/etc/apt/sources.list.d/dyuti.sources"

mkdir -p "${OUT_DIR}"
dpkg-deb --root-owner-group --build "${PKG}" "${OUT_DIR}/dyuti-archive-keyring.deb"
echo "==> built ${OUT_DIR}/dyuti-archive-keyring.deb"
echo "    Copy it into the build and install it in chroot to wire updates in."
