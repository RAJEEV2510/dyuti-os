#!/usr/bin/env bash
# Resync changed source into the WSL clone and run an INCREMENTAL ISO rebuild.
# Must be run as root inside WSL. Invoke via a file (not `bash -lc "<vars>"`),
# because the Claude Bash tool's Git-Bash layer expands $vars in inline wsl
# payloads to empty -- which once turned an rsync into `rsync // //`. Keeping
# all logic in this file means $SRC/$DST are only ever evaluated by WSL bash.
#
#   wsl -d Ubuntu-24.04 -u root -- bash /tmp/rb.sh
#
set -euo pipefail
SRC=/mnt/d/selfProjects/dyuti-os
DST=/root/dyuti-os

echo "=== [1/5] sync source dirs (explicit paths; never /) ==="
for d in config branding chroot tools; do
  rsync -a --no-perms --no-owner --no-group "$SRC/$d/" "$DST/$d/"
  echo "  synced $d/"
done
# build/ holds the stage scripts; never sync work/ (the multi-GB chroot cache).
rsync -a --no-perms --no-owner --no-group --exclude 'work/' "$SRC/build/" "$DST/build/"
echo "  synced build/ (excluding work/)"

echo "=== [2/5] fix DrvFs perms (777 -> sane; dpkg-deb is strict) ==="
find "$DST/branding" -type d -exec chmod 0755 {} +
find "$DST/branding" -type f -exec chmod 0644 {} +
for f in control postinst postrm preinst; do
  [ -f "$DST/branding/dyuti-branding/DEBIAN/$f" ] && chmod 0755 "$DST/branding/dyuti-branding/DEBIAN/$f"
done

echo "=== [3/5] strip CRLF on scripts/lists ==="
find "$DST" -path "$DST/build/work" -prune -o \( -name '*.sh' -o -name '*.list' \) -type f -print \
  | while read -r f; do sed -i 's/\r$//' "$f"; done
for f in control postinst postrm preinst; do
  [ -f "$DST/branding/dyuti-branding/DEBIAN/$f" ] && sed -i 's/\r$//' "$DST/branding/dyuti-branding/DEBIAN/$f"
done

echo "=== [4/5] verify Kvantum files present ==="
ls -l "$DST/branding/dyuti-branding/usr/share/Kvantum/Dyuti/"
test -f "$DST/branding/dyuti-branding/etc/skel/.config/Kvantum/kvantum.kvconfig"
# widgetStyle is Breeze by design (Kvantum rendered desktop menus dark on first
# boot); just assert SOME style is pinned, not specifically kvantum.
grep -q '^widgetStyle=' "$DST/branding/dyuti-branding/etc/skel/.config/kdeglobals"
grep -q 'qt5-style-kvantum' "$DST/config/package-lists/look.list"
echo "  all Kvantum files present and wired (style=Breeze by design)."

TARGETS="${*:-desktop branding cleanup iso}"
echo "=== [5/5] incremental build: make ${TARGETS} ==="
cd "$DST"
make ${TARGETS}
echo "BUILD_DONE"
ls -lh "$DST"/dist/*.iso
