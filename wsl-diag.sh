#!/usr/bin/env bash
# Why didn't the premount fix work? Check (a) is our script in the initrd,
# (b) what runs in init-premount and in what order, (c) which casper FUNCTION
# calls setup_overlay and when that function runs in init.
ISO=/root/dyuti-os/build/work/iso/casper/initrd
CH=/root/dyuti-os/build/work/chroot

echo "=== is our script in the chroot? ==="
ls -l "$CH"/etc/initramfs-tools/scripts/init-premount/dyuti-load-overlay 2>/dev/null || echo "  MISSING in chroot"

echo
echo "=== does the ISO initrd CONTAIN our premount script? ==="
lsinitramfs "$ISO" 2>/dev/null | grep -iE 'init-premount|dyuti-load-overlay|casper' | head -30

echo
echo "=== unpack & list init-premount scripts (run order) ==="
T=$(mktemp -d); unmkinitramfs "$ISO" "$T" 2>/dev/null || true
R="$T"; [ -d "$T/main" ] && R="$T/main"
echo "  --- scripts/init-premount/ ---"
ls -1 "$R"/scripts/init-premount/ 2>/dev/null
echo "  --- scripts/casper-premount/ (if any) ---"
ls -1 "$R"/scripts/casper-premount/ 2>/dev/null || echo "    (none)"
echo "  --- our script contents (if present) ---"
cat "$R"/scripts/init-premount/dyuti-load-overlay 2>/dev/null || echo "    NOT in initrd"
rm -rf "$T"

echo
echo "=== which casper function calls setup_overlay (line 145 context)? ==="
sed -n '120,150p' "$CH"/usr/share/initramfs-tools/scripts/casper
echo "  --- function headers around there ---"
grep -nE '^[a-z_]+\(\)' "$CH"/usr/share/initramfs-tools/scripts/casper | head -40
