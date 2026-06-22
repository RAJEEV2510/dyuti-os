#!/usr/bin/env bash
# Dyuti OS — shared helpers used by every stage.

set -euo pipefail

# ---- pretty logging -----------------------------------------------------------
_c_blue=$'\033[1;34m'; _c_grn=$'\033[1;32m'; _c_red=$'\033[1;31m'
_c_yel=$'\033[1;33m'; _c_rst=$'\033[0m'

log()  { echo "${_c_blue}==>${_c_rst} $*"; }
ok()   { echo "${_c_grn}  ok${_c_rst} $*"; }
warn() { echo "${_c_yel}  ! ${_c_rst} $*" >&2; }
die()  { echo "${_c_red}error:${_c_rst} $*" >&2; exit 1; }

# ---- guards -------------------------------------------------------------------
require_root() {
  [[ "${EUID}" -eq 0 ]] || die "this stage needs root — run with sudo"
}

require_cmd() {
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "missing tool: $c (see README toolchain)"
  done
}

require_linux() {
  [[ "$(uname -s)" == "Linux" ]] || die "the build must run on Linux (WSL2 or a Linux VM)"
}

# ---- chroot mount management --------------------------------------------------
mount_chroot() {
  local root="$1"
  log "mounting virtual filesystems into chroot"
  mount -t proc  proc   "${root}/proc"
  mount -t sysfs sysfs  "${root}/sys"
  mount -o bind  /dev   "${root}/dev"
  mount -o bind  /dev/pts "${root}/dev/pts"
  # resolv.conf so apt inside the chroot can reach the network
  cp /etc/resolv.conf "${root}/etc/resolv.conf"
}

umount_chroot() {
  local root="$1"
  log "unmounting chroot filesystems"
  # umount in reverse, ignore if already gone
  for m in dev/pts dev sys proc; do
    if mountpoint -q "${root}/${m}"; then
      umount -lf "${root}/${m}" || warn "could not umount ${root}/${m}"
    fi
  done
}

# Run a command inside the chroot with a clean, non-interactive apt environment.
chroot_exec() {
  local root="$1"; shift
  DEBIAN_FRONTEND=noninteractive LC_ALL=C LANG=C \
    chroot "${root}" /usr/bin/env DEBIAN_FRONTEND=noninteractive "$@"
}

# Read a package list file (ignoring # comments / blank lines) into a string.
read_pkg_list() {
  local f="$1"
  [[ -f "$f" ]] || die "package list not found: $f"
  grep -vE '^\s*(#|$)' "$f" | tr '\n' ' '
}
