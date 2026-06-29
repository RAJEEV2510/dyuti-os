#!/usr/bin/env bash
# Resume the Dyuti OS build after stage 30 was interrupted mid-apt.
set -uo pipefail
cd /root/dyuti-os
source build/config.sh
source build/lib.sh

echo "==> [resume] repairing interrupted dpkg state in chroot"
mount_chroot "${CHROOT_DIR}"
chroot_exec "${CHROOT_DIR}" dpkg --configure -a || true
chroot_exec "${CHROOT_DIR}" apt-get -f install -y || true
umount_chroot "${CHROOT_DIR}"
echo "  ok [resume] dpkg repair done"

set -e
for s in 30-desktop 40-branding 50-cleanup 60-iso; do
  echo "==================== STAGE ${s} ===================="
  bash build/build.sh "${s}"
done
echo "BUILD COMPLETE"
ls -lh /root/dyuti-os/dist/ || true
