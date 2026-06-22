#!/usr/bin/env bash
# One-time setup of the Dyuti APT repository:
#   1. generate the GPG signing key (4096-bit RSA, no expiry) if missing
#   2. export the public key for the client keyring package
#   3. create the aptly repo and publish it (empty to start)
#
# Run on your repo server (or locally, then rsync the published tree up).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${HERE}/config.sh"

command -v aptly >/dev/null || { echo "install aptly first: sudo apt install aptly"; exit 1; }
command -v gpg   >/dev/null || { echo "install gnupg first: sudo apt install gnupg"; exit 1; }

# --- 1. signing key -----------------------------------------------------------
if ! gpg --list-secret-keys "${GPG_EMAIL}" >/dev/null 2>&1; then
  echo "==> generating signing key for ${GPG_EMAIL}"
  BATCH="$(mktemp)"
  cat > "${BATCH}" <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: ${GPG_NAME}
Name-Email: ${GPG_EMAIL}
Expire-Date: 0
%commit
EOF
  gpg --batch --gen-key "${BATCH}"
  rm -f "${BATCH}"
else
  echo "==> signing key already exists"
fi

# --- 2. export public key -----------------------------------------------------
mkdir -p "${KEYS_DIR}"
gpg --armor --export "${GPG_EMAIL}" > "${KEYS_DIR}/dyuti-archive-keyring.asc"
gpg --export "${GPG_EMAIL}"        > "${KEYS_DIR}/dyuti-archive-keyring.gpg"
echo "==> public key exported to ${KEYS_DIR}/"

# --- 3. create + publish repo -------------------------------------------------
if ! aptly repo show "${REPO_NAME}" >/dev/null 2>&1; then
  aptly repo create -distribution="${REPO_DIST}" -component="${REPO_COMPONENT}" "${REPO_NAME}"
fi

if aptly publish list -raw | grep -q "\\. ${REPO_DIST}\$"; then
  aptly publish update -gpg-key="${GPG_EMAIL}" "${REPO_DIST}"
else
  aptly publish repo -architectures="${REPO_ARCHS}" -gpg-key="${GPG_EMAIL}" "${REPO_NAME}"
fi

echo "==> done. Published tree: ${APTLY_ROOT}/public"
echo "    Serve that directory at ${REPO_PUBLIC_URL} (nginx/Caddy), or use 'aptly serve'."
