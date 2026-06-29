#!/usr/bin/env bash
# Rebuild Dyuti OS to pick up the latest branding (Tela icons + photo wallpapers).
# Re-runs desktop->iso; stage 30 is idempotent so the second pass is fast.
set -euo pipefail
cd /root/dyuti-os
for s in 30-desktop 40-branding 50-cleanup 60-iso; do
  echo "==================== STAGE ${s} ===================="
  bash build/build.sh "${s}"
done
echo "BUILD COMPLETE"
ls -lh /root/dyuti-os/dist/ || true
