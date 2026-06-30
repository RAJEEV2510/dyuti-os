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

# ---- Languages shipped (all 22 Eighth-Schedule languages + English India) -----
# Locale codes; input methods (IBus + m17n) + fonts are wired in
# chroot/install-languages.sh. Every code below has a glibc locale (verified in
# /usr/share/i18n/SUPPORTED). Default UI stays English (India); users switch to
# their language via System Settings → Region & Language.
#   as=Assamese bn=Bengali brx=Bodo doi=Dogri gu=Gujarati hi=Hindi kn=Kannada
#   ks=Kashmiri kok=Konkani mai=Maithili ml=Malayalam mni=Manipuri mr=Marathi
#   ne=Nepali or=Odia pa=Punjabi sa=Sanskrit sat=Santali sd=Sindhi ta=Tamil
#   te=Telugu ur=Urdu
export SHIP_LOCALES="en_IN as_IN bn_IN brx_IN doi_IN gu_IN hi_IN kn_IN ks_IN kok_IN mai_IN ml_IN mni_IN mr_IN ne_NP or_IN pa_IN sa_IN sat_IN sd_IN ta_IN te_IN ur_IN"
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
