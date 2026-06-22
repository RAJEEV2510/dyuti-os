# Dyuti OS (working name)

An original, smooth-UX desktop Linux distribution built for India — for everyday
consumers **and** government bodies. Built on **Ubuntu 24.04 LTS** with a
reshaped **KDE Plasma** desktop, Indian-language support out of the box, and an
India-hosted update/security backbone.

> **Name is a placeholder.** "Dyuti" (Sanskrit: *radiance / light*) is the
> working name. Everything is parameterised in `build/config.sh`, so the brand
> can be swapped in one place later.

---

## What this repo produces

A scripted, reproducible pipeline that builds a bootable, installable **live ISO**:

```
Ubuntu 24.04 base  →  KDE Plasma desktop  →  curated apps  →  Indian languages
   →  your branding package  →  Calamares installer  →  hybrid BIOS+UEFI ISO
```

The output is `dist/dyuti-<version>-amd64.iso`.

---

## Build environment (you are on Windows)

The ISO **must be built on Linux**. Two options:

### Option A — WSL2 (fastest to start)
```powershell
wsl --install -d Ubuntu-24.04
```
Then open the Ubuntu shell and continue below. (Note: the final ISO-assembly
step uses loop/squashfs tooling — WSL2 handles chroot + debootstrap fine; if the
ISO step misbehaves, use Option B.)

### Option B — a real Ubuntu 24.04 VM or machine (most reliable)
Use VirtualBox/VMware/Hyper-V or bare metal running Ubuntu 24.04.

### Install the toolchain (inside Linux)
```bash
sudo apt update
sudo apt install -y debootstrap squashfs-tools xorriso grub-pc-bin \
  grub-efi-amd64-bin grub-common mtools dosfstools rsync ca-certificates
```

---

## Quick start

```bash
git clone <this-repo> dyuti-os
cd dyuti-os
sudo make build        # runs all stages → dist/*.iso
```

Test the ISO in a VM:
```bash
qemu-system-x86_64 -enable-kvm -m 4096 -cdrom dist/dyuti-*.iso
```

Run a single stage (see `build/stages/`):
```bash
sudo make bootstrap        # stage 10 only
sudo make iso              # stage 60 only
sudo make clean            # remove the work tree
```

---

## Layout

| Path | Purpose |
|---|---|
| `build/config.sh` | **All** tunables: name, version, base suite, mirror, arch |
| `build/build.sh` | Orchestrator — runs stages in order |
| `build/lib.sh` | Shared helpers (logging, mount/umount, chroot exec) |
| `build/stages/` | The pipeline: bootstrap → configure → desktop → branding → cleanup → iso |
| `chroot/` | Scripts that run *inside* the chroot (desktop, system, languages) |
| `config/package-lists/` | Package sets (desktop / apps / languages) |
| `branding/dyuti-branding/` | The branding `.deb` source (theme, wallpaper, os-release) |
| `docs/` | Architecture, build notes, roadmap |
| `dist/` | Output ISOs (git-ignored) |

---

## Status

`v0.1-alpha` — Quarter-1, Month-1 target: first bootable, branded ISO.
See `docs/ROADMAP.md`.

## Licensing note

This builds on Ubuntu/Debian packages under their respective open-source
licenses (mostly GPL). You may rebrand and distribute, but you must honour those
licenses and **must not** imply Canonical/Ubuntu endorsement. Keep your own
trademark on the brand assets in `branding/`. See `docs/ARCHITECTURE.md`.
