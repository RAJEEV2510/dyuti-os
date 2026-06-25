#!/usr/bin/env bash
# Sync the changed source files into the WSL clone, validate, then do an
# INCREMENTAL rebuild (reuse the cached chroot; skip debootstrap).
set -e
SRC=/mnt/d/projects/dyuti-os
DST=/root/dyuti-os

echo "=== syncing changed files ==="
cp "$SRC/chroot/configure-system.sh"          "$DST/chroot/configure-system.sh"
cp "$SRC/config/package-lists/apps.list"      "$DST/config/package-lists/apps.list"
cp "$SRC/config/package-lists/desktop.list"   "$DST/config/package-lists/desktop.list"
cp "$SRC/config/package-lists/languages.list" "$DST/config/package-lists/languages.list"
echo "  copied 4 files"

echo "=== syntax check ==="
bash -n "$DST/chroot/configure-system.sh" && echo "  configure-system.sh OK"

echo "=== confirm fixes present ==="
echo -n "  premount script line: "; grep -c "init-premount/dyuti-load-overlay" "$DST/chroot/configure-system.sh"
grep -hE "kde-spectacle|kde-config-sddm|breeze-gtk-theme|fonts-lohit-taml|hunspell-en-gb" "$DST"/config/package-lists/*.list

echo "=== INCREMENTAL build (desktop -> branding -> cleanup -> iso) ==="
cd "$DST"
make desktop branding cleanup iso
echo "BUILD_DONE rc=$?"
ls -lh "$DST"/dist/*.iso
