#!/usr/bin/env bash
# Dyuti OS — build orchestrator.
#
#   bash build/build.sh all            # run every stage in order
#   bash build/build.sh 30-desktop     # run a single stage
#   bash build/build.sh clean          # remove the working tree
#
# Stages live in build/stages/ and are named NN-name.sh so they sort in order.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${HERE}/config.sh"
source "${HERE}/lib.sh"

STAGES=(
  "10-bootstrap"
  "20-configure"
  "30-desktop"
  "40-branding"
  "50-cleanup"
  "60-iso"
)

run_stage() {
  local name="$1"
  local script="${HERE}/stages/${name}.sh"
  [[ -f "${script}" ]] || die "no such stage: ${name}"
  log "STAGE ${name}"
  bash "${script}"
  ok "STAGE ${name} complete"
}

cmd="${1:-all}"

case "${cmd}" in
  all)
    require_linux
    require_root
    mkdir -p "${WORK_DIR}" "${OUT_DIR}"
    for s in "${STAGES[@]}"; do run_stage "${s}"; done
    ok "BUILD COMPLETE → ${OUTPUT_ISO}"
    ;;
  clean)
    log "removing ${WORK_DIR}"
    # make sure nothing is still mounted before deleting
    [[ -d "${CHROOT_DIR}" ]] && umount_chroot "${CHROOT_DIR}" || true
    rm -rf "${WORK_DIR}"
    ok "clean done"
    ;;
  *)
    require_linux
    require_root
    mkdir -p "${WORK_DIR}" "${OUT_DIR}"
    run_stage "${cmd}"
    ;;
esac
