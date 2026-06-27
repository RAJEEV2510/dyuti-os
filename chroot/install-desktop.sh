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

# --- Tela icon theme (modern, simple; saffron via the 'orange' variant) -------
# Not in the Ubuntu repos, so fetch vinceliuice's installer at build time. It
# installs Tela-orange (light) + Tela-orange-dark (dark) into /usr/share/icons
# pre-coloured to our saffron accent — no per-folder recolor needed. Resilient:
# a network failure leaves Papirus (still installed) as the fallback default.
say "installing Tela icon theme (orange)"
apt_install_soft git
if git clone --depth 1 https://github.com/vinceliuice/Tela-icon-theme /tmp/Tela 2>/dev/null; then
  ( cd /tmp/Tela && ./install.sh orange ) || say "WARN: Tela install script failed — keeping Papirus"
  rm -rf /tmp/Tela
else
  say "WARN: could not clone Tela-icon-theme — keeping Papirus as icon default"
fi

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

# --- real web browser: Google Chrome (.deb) -----------------------------------
# Ubuntu's `firefox`/`chromium` packages are just snap stubs that can't run in
# our snap-less casper live image. Ship Chrome from Google's own apt repo, and
# drop the broken Firefox stub (+ snapd) so users get a browser that works.
say "installing Google Chrome (real .deb browser)"
apt_install_soft curl ca-certificates gnupg
install -d -m 0755 /etc/apt/keyrings
# Download to a file first, then dearmor from that file with stdin closed.
# Piping curl into `gpg --dearmor` (which reads stdin) hangs forever in a
# non-interactive/background build where stdin never sees EOF.
if curl -fsSL --max-time 60 https://dl.google.com/linux/linux_signing_key.pub -o /tmp/google-key.pub \
   && gpg --batch --yes --no-tty --dearmor -o /etc/apt/keyrings/google-chrome.gpg /tmp/google-key.pub </dev/null; then
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list
  apt-get update
  apt_install_soft google-chrome-stable
else
  say "WARN: could not fetch Google signing key — Chrome NOT installed"
fi
say "removing the broken Firefox snap stub and snapd"
apt-get purge -y firefox snapd >/dev/null 2>&1 || true

# --- virtual-machine guest tools (auto-resize + clipboard in VirtualBox) -------
say "installing VirtualBox guest additions"
apt_install_soft virtualbox-guest-utils virtualbox-guest-x11

# --- system tuning ------------------------------------------------------------
bash "${HERE}/configure-system.sh"

# --- strip upstream branding --------------------------------------------------
bash "${HERE}/rebrand.sh"

say "desktop install finished"
