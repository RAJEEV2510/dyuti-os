#!/usr/bin/env bash
# Stage 10 — debootstrap a minimal base system into the chroot.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${HERE}/config.sh"
source "${HERE}/lib.sh"

require_root
require_cmd debootstrap

if [[ -d "${CHROOT_DIR}/usr/bin" ]]; then
  warn "chroot already exists at ${CHROOT_DIR}; skipping bootstrap (run 'make clean' to redo)"
  exit 0
fi

mkdir -p "${CHROOT_DIR}"

log "debootstrap ${BASE_SUITE} (${ARCH}) from ${BASE_MIRROR}"
debootstrap \
  --arch="${ARCH}" \
  --variant=minbase \
  --components="${BASE_COMPONENTS}" \
  --include=ca-certificates,gnupg,locales,apt-utils \
  "${BASE_SUITE}" \
  "${CHROOT_DIR}" \
  "${BASE_MIRROR}"

ok "base system bootstrapped into ${CHROOT_DIR}"
