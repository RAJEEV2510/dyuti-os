#!/usr/bin/env bash
# Runs INSIDE the chroot. Installs kernel + live boot, KDE Plasma, curated apps,
# look & feel, codecs, Flatpak store, languages, and the Calamares installer.
# Reads package lists from /tmp/dyuti-build/lists/.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

LISTS="/tmp/dyuti-build/lists"
HERE="/tmp/dyuti-build"

say() { echo "  [chroot] $*"; }
read_list() { grep -vE '^\s*(#|$)' "$1" | sed 's/[[:space:]]*#.*$//' | tr '\n' ' '; }

# Strict install — must succeed (used for core desktop).
apt_install() { apt-get install -y --no-install-recommends "$@"; }

# Soft install — try the whole batch; if it fails (e.g. one renamed package),
# fall back to installing each package individually and skip the missing ones,
# so a single bad name never kills the build. Used for apps / look / codecs.
apt_install_soft() {
  if apt-get install -y --no-install-recommends "$@"; then
    return 0
  fi
  say "batch had a missing package — retrying individually"
  for p in "$@"; do
    apt-get install -y --no-install-recommends "$p" \
      || say "  skipped (unavailable): $p"
  done
}

say "apt update"
apt-get update

# --- kernel + live-boot (strict) ----------------------------------------------
say "installing kernel + casper (live boot)"
apt_install \
  linux-generic casper \
  discover laptop-detect os-prober \
  network-manager systemd-sysv sudo

# --- desktop: a tiny essential set is strict, the rest is resilient -----------
say "installing desktop essentials"
apt_install plasma-desktop plasma-workspace sddm xserver-xorg
say "installing remaining desktop packages"
apt_install_soft $(read_list "${LISTS}/desktop.list")

# --- curated default applications (soft) --------------------------------------
say "installing default applications"
apt_install_soft $(read_list "${LISTS}/apps.list")

# --- GUI polish layer: themes, fonts, icons, plymouth (soft) ------------------
say "installing look & feel layer"
apt_install_soft $(read_list "${LISTS}/look.list")

# --- multimedia codecs so media just works (soft) -----------------------------
say "installing multimedia codecs"
apt_install_soft $(read_list "${LISTS}/multimedia.list")

# --- Flatpak + Flathub + Discover backend (the GUI app store) -----------------
say "enabling Flatpak app store (Flathub)"
apt_install_soft flatpak plasma-discover-backend-flatpak
flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo || true

# --- branded boot splash ------------------------------------------------------
say "selecting a clean plymouth theme (branding pkg overrides with our logo)"
if update-alternatives --list default.plymouth >/dev/null 2>&1; then
  BPLY="$(update-alternatives --list default.plymouth | grep -iE 'bgrt|spinner' | head -n1 || true)"
  [ -n "${BPLY:-}" ] && update-alternatives --set default.plymouth "${BPLY}" || true
fi

# --- languages: fonts + input methods -----------------------------------------
say "installing language packages"
apt_install_soft $(read_list "${LISTS}/languages.list")
bash "${HERE}/install-languages.sh"

# --- Calamares installer (brandable graphical installer) ----------------------
say "installing Calamares installer"
apt_install_soft calamares calamares-settings-debian || apt_install_soft calamares

# --- system tuning ------------------------------------------------------------
bash "${HERE}/configure-system.sh"

# --- strip upstream branding --------------------------------------------------
bash "${HERE}/rebrand.sh"

say "desktop install finished"
