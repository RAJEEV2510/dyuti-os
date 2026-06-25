#!/usr/bin/env bash
# Post-build audit: ISO size, which NEW packages actually installed, and why
# the skipped ones are unavailable (probe apt for the correct names).
set -e
CH=/root/dyuti-os/build/work/chroot

echo "=== ISO ==="
ls -lh /root/dyuti-os/dist/*.iso

echo
echo "=== did our NEW packages install into the chroot? ==="
for p in wine winetricks fonts-wine ubuntu-drivers-common fwupd \
         kdeconnect plasma-firewall plasma-browser-integration \
         kdialog kde-cli-tools fonts-inter \
         plasma-discover-backend-flatpak plasma-discover-backend-fwupd; do
  if chroot "$CH" dpkg -s "$p" >/dev/null 2>&1; then
    echo "  OK   $p"
  else
    echo "  MISS $p"
  fi
done

echo
echo "=== probe correct names for the skipped packages (apt-cache in chroot) ==="
for q in spectacle sddm-kcm breeze-gtk fonts-tamil hunspell-en-in; do
  echo "--- candidates for: $q ---"
  chroot "$CH" bash -c "apt-cache search '$q' 2>/dev/null | head -4; \
    echo 'tamil/lohit/noto-taml:'; apt-cache search 'tamil|lohit-taml|noto.*tamil' 2>/dev/null | head -4" \
    2>/dev/null || echo "  (apt-cache unavailable)"
done
