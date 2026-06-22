# Known issues & validation status

Honest status of the scaffold. "Static-verified" = checked by reading/syntax.
"Needs a build run" = can only be confirmed by actually building/booting the ISO.

## Fixed (static)
- Empty default panel → now ships a complete panel (menu, tasks, tray, clock).
- Wrong package `kde-config-sddm` → `sddm-kcm`; desktop install made resilient
  (only a tiny essential set is strict; the rest skip missing packages).
- GRUB couldn't locate the kernel → added `search --file /casper/vmlinuz`.
- SDDM login referenced missing icon files → replaced with text buttons.
- Squashfs excluded `/boot` → installed systems would have no kernel; now kept.
- Removed a bogus `qmlscene` package entry.

## Needs a build run to confirm (the real remaining risk)
These are correct on paper but unverified until the pipeline actually runs:

1. **ISO assembly** (`60-iso.sh`) — the hybrid BIOS+UEFI `xorriso` invocation is
   intricate; first real build may need a tweak.
2. **Live boot** — casper bringing up the live session + autologin.
3. **Theme application** — Plasma picking up the Dyuti global theme, color
   scheme, and panel on first login.
4. **Custom SDDM theme** — may need adjustment; if it fails, set
   `Current=breeze` in `etc/sddm.conf.d/dyuti.conf` as a safe fallback.
5. **Plymouth script** — boot splash animation; non-critical (boot proceeds even
   if the theme errors).

## Known limitation (not a bug)
- **Installer (Calamares) path is best-effort.** Live boot + try is the alpha
  demo. A fully working *install to disk* needs a complete Calamares
  `settings.conf` + module configs wired to our squashfs; that's a follow-up.
  The branding is in place; the install flow needs validation/config.

## How we'll close these
The fastest way to validate 1–5 is a real build. The cloud CI workflow
(`.github/workflows/build-iso.yml`, pending the `workflow` permission) runs the
whole pipeline on a Linux runner and surfaces any error to fix — no local Linux
needed.
