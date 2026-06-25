#!/usr/bin/env bash
# One-time WSL2 build-environment setup for Dyuti OS.
# Run as root inside Ubuntu-24.04. Installs the toolchain and clones the repo
# into the WSL ext4 filesystem (NOT /mnt/d — debootstrap/chroot need real ext4).
set -e

echo "==> distro"
. /etc/os-release; echo "    $PRETTY_NAME  (kernel $(uname -r))"

echo "==> installing build toolchain"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y \
  git debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin grub-common \
  mtools dosfstools rsync ca-certificates make

REPO=/root/dyuti-os
BRANCH=feature/zorin-parity-design
echo "==> cloning repo into $REPO (branch $BRANCH)"
if [ -d "$REPO/.git" ]; then
  git -C "$REPO" fetch origin
  git -C "$REPO" checkout "$BRANCH"
  git -C "$REPO" pull --ff-only
else
  git clone https://github.com/RAJEEV2510/dyuti-os.git "$REPO"
  git -C "$REPO" checkout "$BRANCH"
fi

echo "==> ready"
git -C "$REPO" log --oneline -3
echo "    free space:"; df -h / | tail -1
