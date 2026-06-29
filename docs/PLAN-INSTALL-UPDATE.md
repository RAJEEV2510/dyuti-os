# Dyuti OS — Installation + Update plan

> Goal: turn the two headline claims that are currently **scaffold only** —
> "graphical installer" and "India-hosted update/security backbone" — into
> things that actually work on a built ISO. Sequenced as **one build batch** so
> the expensive ISO/VM verify loop runs once, not per-edit.

References: `docs/KNOWN-ISSUES.md` (installer "best-effort"), `repo/README.md`
("add a stage that copies + installs the keyring"), `chroot/install-desktop.sh`,
`build/stages/`.

---

## Where we stand (verified by reading the tree)

**Installation** — Calamares is *installed* (`install-desktop.sh:108`) and
*branded* (`branding/.../etc/calamares/branding/dyuti/`), but there is **no
`settings.conf` and no module configs**. It falls back to
`calamares-settings-debian` (Debian-oriented), so install-to-disk is unverified
and effectively non-functional. Never built or booted.

**Updates** — GUI clients ship (`plasma-discover` + flatpak + fwupd backends,
`fwupd`, Flathub). But the Dyuti repo is **not wired into the image**: nothing
references `dyuti-archive-keyring`/`dyuti.sources` outside `repo/`, `config.sh`
still has `example.in` placeholders. Also `packagekit` and `unattended-upgrades`
are absent and everything installs `--no-install-recommends`, so Discover likely
can't apply *apt* updates and there are no automatic security updates.

---

## Phase 0 — one-time repo bring-up (off the build host, do once)

Not part of the ISO build; produces the keyring `.deb` the build will bake in.
Can be **stubbed** for the alpha (Batch 1 step B4 is guarded to skip if absent).

1. Set real values in `repo/config.sh`: `REPO_PUBLIC_URL` (e.g.
   `https://repo.dyuti.in/dyuti`), `GPG_NAME`, `GPG_EMAIL`.
2. On a Linux box: `sudo apt install aptly gnupg` → `./repo/setup-repo.sh`
   (generates signing key + empty signed repo) → `./repo/client/build-keyring-deb.sh`
   (emits `repo/client/out/dyuti-archive-keyring.deb`).
3. Stand up the India HTTPS host serving the published tree at `REPO_PUBLIC_URL`.
   (Server provisioning is its own task — see Roadmap "India server".)

---

## Batch 1 — "Real install + real updates" (one `make build` + one VM verify)

### A. Make install-to-disk actually work (Calamares)

All files ship via the **branding `.deb`** under
`branding/dyuti-branding/etc/calamares/` (installed in stage 40), so no new build
stage is needed for the installer itself.

**A1. Stop using the Debian defaults.** In `chroot/install-desktop.sh:109`
install **only** `calamares` (drop `calamares-settings-debian`) so our own
`/etc/calamares/settings.conf` doesn't dpkg-conflict with theirs.

**A2. Write `etc/calamares/settings.conf`** — `branding: [dyuti]`, modules search
path, and an exec/show **sequence** suited to a casper squashfs image:
`show:` welcome, locale, keyboard, partition, users, summary →
`exec:` partition, mount, unpackfs, machineid, fstab, locale, keyboard,
localecfg, luksbootkeyfile(off for now), users, displaymanager, networkcfg,
hwclock, services-systemd, initramfscfg, initramfs, grubcfg, bootloader,
packages, umount → `show:` finished.

**A3. Write the module configs** under `etc/calamares/modules/`:
- `unpackfs.conf` → source `/cdrom/casper/filesystem.squashfs`, `sourcefs:
  squashfs`, destination `""` (the casper live medium mounts at `/cdrom`; our
  squashfs path matches `60-iso.sh`).
- `bootloader.conf` → `efiBootLoader: grub`, `efiBootloaderId: Dyuti`,
  `grubInstall/grubMkconfig/grubCfg` set — must cover **BIOS + UEFI** to match
  the hybrid ISO.
- `partition.conf` → enable EFI system partition, sane swap default.
- `users.conf` → default groups (sudo, adm, …), `sudoersGroup: sudo`,
  password policy, hostname prefix `dyuti`.
- `packages.conf` → on the **target**, `try_remove` the live-only packages
  (`casper`, `calamares`, `calamares-settings-*`, `live-boot*`,
  `virtualbox-guest-*`) so installed systems are clean.
- `locale.conf` / `keyboard.conf` → defaults from `build/config.sh`
  (`DEFAULT_LOCALE=en_IN.UTF-8`, `SHIP_LOCALES`).
- `displaymanager.conf` → `sddm`, Plasma session.
- `finished.conf`, `welcome.conf` (requirements/space checks), `grubcfg.conf`,
  `initramfs*.conf`, `fstab.conf`, `machineid.conf` → standard values.

**A4. Add a visible "Install Dyuti OS" entry** for the live session:
- ship `etc/skel/Desktop/install-dyuti.desktop` (Exec: `pkexec calamares`) and a
  Kickoff/menu entry `usr/share/applications/install-dyuti.desktop`.
- wire the **Welcome app** Install button (`usr/share/dyuti-welcome/Welcome.qml`)
  to launch the same. (Calamares ships its own polkit policy; verify pkexec
  prompt works in the live session.)

**A5. Sanity prereqs (already met):** `squashfs-tools` (→ `unsquashfs`) and
`grub-pc-bin`/`grub-efi-amd64-bin` are present in the build toolchain; confirm
`unsquashfs` exists *inside* the live image (add `squashfs-tools` to
`desktop.list` if not).

### B. Wire the update backbone + fix Discover

**B1. Package lists** (`config/package-lists/desktop.list`): add
`packagekit`, `packagekit-tools`, `appstream` (so Discover's PackageKit backend
can show/apply **apt** updates — today only Flatpak/fwupd would work under
`--no-install-recommends`) and `unattended-upgrades`.

**B2. Automatic security updates** — ship under the branding deb:
- `etc/apt/apt.conf.d/52dyuti-periodic` → enable
  `APT::Periodic::Update-Package-Lists "1"` + `Unattended-Upgrade "1"`.
- `etc/apt/apt.conf.d/51dyuti-unattended` → `Unattended-Upgrade::Origins-Pattern`
  including Ubuntu `-security` **and** the Dyuti origin (`o=Dyuti`), plus
  `Automatic-Reboot "false"`.

**B3. Discover update channel** — confirm the Dyuti origin and Ubuntu updates
both surface in Discover after B1 (PackageKit daemon running). No extra backend
needed beyond `packagekit`.

**B4. Bake in the Dyuti keyring (guarded).** Add to `install-desktop.sh` (or a
small new `chroot/install-updates.sh` called from it): if
`repo/client/out/dyuti-archive-keyring.deb` is present in the build context,
copy it into the chroot and `dpkg -i` it (installs the signing key +
`/etc/apt/sources.list.d/dyuti.sources`); **skip cleanly if absent** so the
build never fails before Phase 0 is done. Mirror the file-copy pattern stage 40
already uses for the branding deb.

### C. Verify (single VM pass — the expensive step, run once)

Build `sudo make build`, boot `dist/*.iso` in a VM, then:
1. Live desktop shows an **Install Dyuti OS** icon; launching it opens Calamares.
2. Run a full guided install to a virtual disk → completes without error.
3. **Reboot into the installed system** (not the live ISO): logs in via SDDM.
4. `apt-get update` reaches the Dyuti repo (if Phase 0 done) + Ubuntu; Discover
   "Updates" page lists system + firmware + flatpak updates.
5. `systemctl status unattended-upgrades` / `apt-config dump | grep Periodic`
   confirm auto-updates are armed.
6. Confirm live-only packages (`casper`, `calamares`) are **absent** on the
   installed target (packages module ran).

---

## Deferred (later batches — each its own verify loop)

Tracked here so they aren't lost; **not** in Batch 1.

- **I-5 LUKS full-disk encryption** option in `partition`/`luks*` modules (govt P0).
- **I-6 Secure Boot** — signed shim + signed GRUB so UEFI Secure Boot installs.
- **I-7 OEM / preseed / unattended** install mode (OEM preloads, govt fleets).
- **U-5 Key custody** — move signing key off `%no-protection` to HSM + documented
  rotation (auditor/government requirement).
- **U-6 Free/Pro edition gating** through the repo (monetization).
- **U-7 Mirror/CDN + delta updates**; single `REPO_PUBLIC_URL` today.
- **U-8 Rollback UX** — Timeshift is installed but has no recovery flow; no
  livepatch/kernel story.
- **U-9 Branding-deb update channel** so post-install theme/fixes can be pushed.

---

## Workflow reminder (per repo convention)
1. Edit under `branding/dyuti-branding/`, `config/package-lists/`, `chroot/`.
2. New packages (B1) need the package stage: `sudo make desktop` then `make iso`
   (or a full `make build`). Calamares config (A) ships via branding → `make
   refresh` would pick it up, **but** because Batch 1 also adds packages, run a
   **full `make build`** once to do everything in a single chroot pass.
3. Boot `dist/*.iso` in a VM and run the Section C checklist.
4. Commit per logical unit (installer config; update wiring) with focused messages.
