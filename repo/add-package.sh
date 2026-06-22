#!/usr/bin/env bash
# Add one or more .deb packages to the Dyuti repo and re-publish (signed).
#   ./add-package.sh ../build/work/pkgs/dyuti-branding.deb
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${HERE}/config.sh"

[[ $# -ge 1 ]] || { echo "usage: $0 <package.deb> [more.deb ...]"; exit 1; }

for deb in "$@"; do
  [[ -f "${deb}" ]] || { echo "not found: ${deb}"; exit 1; }
  echo "==> adding ${deb}"
  aptly repo add "${REPO_NAME}" "${deb}"
done

echo "==> publishing (signed by ${GPG_EMAIL})"
aptly publish update -gpg-key="${GPG_EMAIL}" "${REPO_DIST}"
echo "==> done. Run your rsync/deploy to push ${APTLY_ROOT}/public to the server."
