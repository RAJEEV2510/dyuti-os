# Dyuti OS (working name)

An original, smooth-UX desktop operating system built for India — for everyday
consumers **and** government bodies. Dyuti pairs a stable, long-term-support
Linux foundation with a fully reshaped, modern desktop, Indian-language support
out of the box, and an India-hosted update/security backbone.

> **Name is a placeholder.** "Dyuti" (Sanskrit: *radiance / light*) is the
> working name. Everything is parameterised in `build/config.sh`, so the brand
> can be swapped in one place later.

---

## What this repo produces

A scripted, reproducible pipeline that builds a bootable, installable **live ISO**:

```
stable Linux base  →  reshaped desktop  →  curated apps  →  Indian languages
   →  Dyuti branding  →  graphical installer  →  hybrid BIOS+UEFI ISO
```

The output is `dist/dyuti-<version>-amd64.iso`. The base is Ubuntu **24.04 LTS
(noble)** — Plasma 5.27 / Qt5 — and the build can also run **automatically in the
cloud** via the `build-iso.yml` GitHub Actions workflow.

---

## The desktop

Dyuti ships its own design system, not a stock Plasma theme:

- **Dyuti light theme is the default**, with a matching **dark** theme. Both are
  custom Kvantum + Plasma color schemes (`Dyuti` / `DyutiLight`), with GTK 3/4
  CSS so apps stay consistent. A one-click **theme toggle** (`dyuti-theme`) and a
  first-boot theme applier (`dyuti-firstboot-theme`) keep everything in sync.
- **Branded photo wallpapers** plus original SVG wallpapers (light, dark,
  lockscreen, bloom, mountain), and the **Tela** icon theme.
- **Layout switcher** (`dyuti-layouts`) to flip the panel between a modern Dyuti,
  **macOS-style**, and **Windows-classic** layout.
- A **driver manager** (`dyuti-drivers`) and a first-boot **Welcome** app.
- A unified design language documented in `docs/DESIGN-SYSTEM.md` and
  `docs/design-tokens.md` (saffron accent, light-first, ≤150 ms motion).

---

## Build environment (you are on Windows)

The ISO **must be built on Linux**. Two options:

### Option A — WSL2 (fastest to start)
```powershell
wsl --install
```
Then open the Linux shell and continue below. (Note: the final ISO-assembly
step uses loop/squashfs tooling; if it misbehaves on WSL, use Option B.)

### Option B — a Linux VM or machine (most reliable)
Use VirtualBox/VMware/Hyper-V or bare metal running a current Linux release.

### Install the toolchain (inside Linux)
```bash
sudo apt update
sudo apt install -y debootstrap squashfs-tools xorriso grub-pc-bin \
  grub-efi-amd64-bin grub-common mtools dosfstools rsync ca-certificates make
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
| `build/config.sh` | **All** tunables: name, version, base, mirror, arch |
| `build/build.sh` | Orchestrator — runs stages in order |
| `build/lib.sh` | Shared helpers (logging, mount/umount, chroot exec) |
| `build/stages/` | The pipeline: bootstrap → configure → desktop → branding → cleanup → iso |
| `chroot/` | Scripts that run *inside* the chroot (desktop, system, languages, rebrand) |
| `config/package-lists/` | Package sets (desktop / apps / look / multimedia / languages) |
| `branding/dyuti-branding/` | The Dyuti branding `.deb` (themes, wallpapers, icons, splash, login, layouts, tools, installer) |
| `repo/` | Signed APT repository scaffold (update/security backbone) |
| `tools/` | Helpers (e.g. `gen-kvantum-svg.py` to generate Kvantum theme assets) |
| `wsl-*.sh` | WSL build helpers (setup, sync, resync, diagnostics) |
| `.github/workflows/` | `build-iso.yml` — cloud CI that builds the ISO |
| `docs/` | Architecture, build notes, roadmap, design system, rebranding, plans |
| `dist/` | Output ISOs (git-ignored) |

---

## Docs

- `docs/ARCHITECTURE.md`, `docs/BUILDING.md`, `docs/ROADMAP.md` — how it's built and where it's going
- `docs/DESIGN-SYSTEM.md`, `docs/design-tokens.md` — the design language
- `docs/REBRANDING.md` — how upstream marks are stripped/replaced
- `docs/KNOWN-ISSUES.md` — current rough edges
- `docs/PLAN-*.md` — in-progress plans (panel, task manager, theme unification, beating Zorin/BOSS)

---

## Status

`v0.1-alpha` (codename *prabha*) — bootable, fully-branded ISO with a custom
light/dark design system, layout switcher, and cloud CI. See `docs/ROADMAP.md`
and `docs/KNOWN-ISSUES.md`.

## Licensing note

Dyuti is assembled from open-source components under their respective licenses
(mostly GPL). You may rebrand and distribute, but you must honour those licenses
and provide source. Keep your own trademark on the brand assets in `branding/`.
See `docs/ARCHITECTURE.md`.
