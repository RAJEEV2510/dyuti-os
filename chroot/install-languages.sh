#!/usr/bin/env bash
# Runs INSIDE the chroot. Wires up Indian-language input (IBus + m17n) and makes
# the default locale active. Fonts come from languages.list.
#
# Lean alpha set (from SHIP_LOCALES): English (India), Hindi, Tamil, Bengali.
# Expand by adding locales to build/config.sh and fonts to languages.list.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
say() { echo "  [chroot] $*"; }

SHIP_LOCALES="${SHIP_LOCALES:-en_IN hi_IN ta_IN bn_IN}"
DEFAULT_LOCALE="${DEFAULT_LOCALE:-en_IN.UTF-8}"

# --- IBus + m17n: the input-method framework for Indic scripts ----------------
say "installing IBus + m17n input methods"
apt-get install -y --no-install-recommends \
  ibus ibus-m17n m17n-db im-config

# Make IBus the system input-method framework.
say "selecting ibus via im-config"
im-config -n ibus || true

# --- regenerate locales (config.sh already seeded /etc/locale.gen) ------------
say "ensuring locales generated"
for loc in ${SHIP_LOCALES}; do
  grep -q "^${loc}.UTF-8" /etc/locale.gen 2>/dev/null || \
    echo "${loc}.UTF-8 UTF-8" >> /etc/locale.gen
done
locale-gen
update-locale LANG="${DEFAULT_LOCALE}"

say "language setup finished"
