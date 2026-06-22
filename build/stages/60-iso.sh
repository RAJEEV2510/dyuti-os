#!/usr/bin/env bash
# Stage 60 — assemble a bootable hybrid (BIOS + UEFI) live ISO.
#   1. squash the chroot into casper/filesystem.squashfs
#   2. copy kernel + initrd out of the chroot
#   3. write GRUB config with the casper live-boot line
#   4. build EFI + BIOS boot images and stitch the ISO with xorriso

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${HERE}/config.sh"
source "${HERE}/lib.sh"

require_root
require_cmd mksquashfs xorriso grub-mkstandalone
[[ -d "${CHROOT_DIR}/usr/bin" ]] || die "no chroot — run earlier stages first"

rm -rf "${ISO_DIR}"
mkdir -p "${ISO_DIR}/casper" "${ISO_DIR}/boot/grub" "${ISO_DIR}/EFI/boot"

# --- 1. squashfs ---------------------------------------------------------------
# NB: keep /boot inside the squashfs — the installer copies the squashfs to disk,
# so the kernel must be in it or installed systems won't boot. (The live session
# boots from the separate /casper/vmlinuz copy made below.)
log "creating squashfs (this is the slow part)"
mksquashfs "${CHROOT_DIR}" "${ISO_DIR}/casper/filesystem.squashfs" \
  -noappend -comp zstd \
  -e tmp var/cache/apt/archives

# size manifest (used by the installer to show progress)
printf "%s" "$(du -sx --block-size=1 "${CHROOT_DIR}" | cut -f1)" \
  > "${ISO_DIR}/casper/filesystem.size"

# --- 2. kernel + initrd --------------------------------------------------------
log "extracting kernel and initrd"
cp "${CHROOT_DIR}"/boot/vmlinuz-* "${ISO_DIR}/casper/vmlinuz"
cp "${CHROOT_DIR}"/boot/initrd.img-* "${ISO_DIR}/casper/initrd"

# --- 3. GRUB config ------------------------------------------------------------
log "writing grub.cfg"
cat > "${ISO_DIR}/boot/grub/grub.cfg" <<EOF
set default=0
set timeout=10

# Locate the live medium (works for both BIOS El Torito and UEFI standalone).
search --no-floppy --set=root --file /casper/vmlinuz

menuentry "Try or Install ${DISTRO_NAME}" {
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}
menuentry "Try ${DISTRO_NAME} (safe graphics)" {
    linux /casper/vmlinuz boot=casper nomodeset quiet splash ---
    initrd /casper/initrd
}
EOF

# A marker file the live-boot system (casper) looks for to identify the medium.
# (Filename is fixed by the live-boot tooling — functional, not branding.)
touch "${ISO_DIR}/ubuntu"
mkdir -p "${ISO_DIR}/.disk"
echo "${DISTRO_NAME} ${DISTRO_VERSION} \"${DISTRO_CODENAME}\" - live amd64" \
  > "${ISO_DIR}/.disk/info"

# --- 4. boot images ------------------------------------------------------------
log "building UEFI boot image"
grub-mkstandalone \
  --format=x86_64-efi \
  --output="${ISO_DIR}/EFI/boot/bootx64.efi" \
  --locales="" --fonts="" \
  "boot/grub/grub.cfg=${ISO_DIR}/boot/grub/grub.cfg"

# FAT image holding the EFI binary (the El Torito EFI boot catalog entry).
( cd "${ISO_DIR}" && \
  dd if=/dev/zero of=EFI/boot/efiboot.img bs=1M count=10 && \
  mkfs.vfat EFI/boot/efiboot.img && \
  mmd  -i EFI/boot/efiboot.img ::/EFI ::/EFI/BOOT && \
  mcopy -i EFI/boot/efiboot.img ./EFI/boot/bootx64.efi ::/EFI/BOOT/BOOTX64.EFI )

log "building BIOS boot image"
grub-mkstandalone \
  --format=i386-pc \
  --output="${WORK_DIR}/core.img" \
  --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
  --modules="linux normal iso9660 biosdisk search" \
  --locales="" --fonts="" \
  "boot/grub/grub.cfg=${ISO_DIR}/boot/grub/grub.cfg"
cat /usr/lib/grub/i386-pc/cdboot.img "${WORK_DIR}/core.img" \
  > "${ISO_DIR}/boot/grub/bios.img"

# --- 5. stitch ISO -------------------------------------------------------------
mkdir -p "${OUT_DIR}"
log "running xorriso → ${OUTPUT_ISO}"
xorriso -as mkisofs \
  -volid "${DISTRO_ID^^}" \
  -o "${OUTPUT_ISO}" \
  --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 0xEF "${ISO_DIR}/EFI/boot/efiboot.img" \
  -appended_part_as_gpt \
  -eltorito-boot boot/grub/bios.img \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
    -e --interval:appended_partition_2:all:: -no-emul-boot \
  -r -J -joliet-long \
  "${ISO_DIR}"

ok "ISO built: ${OUTPUT_ISO}"
ls -lh "${OUTPUT_ISO}"
