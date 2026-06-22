#!/usr/bin/env bash
# Dyuti OS — central build configuration.
# Change the brand / base / mirror here ONCE; every stage reads these values.

# ---- Brand (working name; swap when the final name is chosen) ----------------
export DISTRO_NAME="Dyuti"                 # Human-facing name
export DISTRO_ID="dyuti"                    # lowercase id (os-release ID=, paths)
export DISTRO_VERSION="0.1-alpha"           # build version
export DISTRO_CODENAME="prabha"             # internal release codename (radiance)
export DISTRO_VENDOR="Dyuti Project"        # vendor string
export DISTRO_URL="https://example.in"      # placeholder until domain is chosen
export DISTRO_TAGLINE="A smooth desktop, made for India."

# ---- Base distro --------------------------------------------------------------
export BASE_SUITE="noble"                   # 24.04 LTS series = noble
# Package archive (software source). Swap to your own India-hosted mirror for
# speed + sovereignty once validated, e.g. http://in.archive.example.in/...
export BASE_MIRROR="http://archive.ubuntu.com/ubuntu"
export BASE_COMPONENTS="main,restricted,universe,multiverse"
export ARCH="amd64"

# ---- Languages shipped in the alpha (lean set; expand later) ------------------
# Locale codes; input methods + fonts are wired in chroot/install-languages.sh
export SHIP_LOCALES="en_IN hi_IN ta_IN bn_IN"
export DEFAULT_LOCALE="en_IN.UTF-8"

# ---- Paths (derived; usually no need to edit) ---------------------------------
export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export WORK_DIR="${REPO_ROOT}/build/work"
export CHROOT_DIR="${WORK_DIR}/chroot"
export ISO_DIR="${WORK_DIR}/iso"
export OUT_DIR="${REPO_ROOT}/dist"
export CONFIG_DIR="${REPO_ROOT}/config"
export CHROOT_SCRIPTS="${REPO_ROOT}/chroot"
export BRANDING_DIR="${REPO_ROOT}/branding"

export OUTPUT_ISO="${OUT_DIR}/${DISTRO_ID}-${DISTRO_VERSION}-${ARCH}.iso"
