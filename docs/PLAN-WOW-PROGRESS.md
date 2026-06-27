# WOW UI Pass — Progress & Resume Plan

> Companion to `PLAN-UI-WOW.md` (the deliverables) and `design-tokens.md` (the
> source of truth). This file tracks **what's done, what's broken, and what's
> next** so we can resume cleanly. Direction is locked: *premium dark, restrained
> saffron accent*.

Last updated: 2026-06-27.

---

## Status at a glance (the 11 deliverables)

| # | Deliverable | State | Notes |
|---|---|---|---|
| 1 | Wallpaper set | ✅ **VERIFIED FIXED in VM (2026-06-27)** | First-login `dyuti-firstboot-theme` autostart force-applies via the live shell. VM shows the charcoal Dyuti wallpaper, not the mountain fallback. |
| 2 | Color scheme (`Dyuti.colors`) | ✅ done | Rebuilt from tokens. |
| 3 | **Kvantum theme** | ✅ done + **VERIFIED in VM** | Saffron focus rings, dark charcoal surfaces, rounded corners all render. `widgetStyle=kvantum`. |
| 4 | Global Look-and-Feel | 🟡 **complete, needs verify** | metadata.json, defaults, splash, layouts all present; metadata description fixed (was "saffron on indigo"). |
| 5 | SDDM login | 🟡 **bug fixed, needs verify on reboot** | Had the same `onAccent` QML signal-handler bug as Welcome (would break the login card) — renamed → `accentInk`. Otherwise token-correct. Needs a real login screenshot. |
| 6 | Plymouth splash | 🟡 **token-aligned, needs verify** | `dyuti.script` retoned: charcoal `#0d0f12`→`#08090b` field, saffron spinner, token text colors (was off-palette indigo). True 1px hairline (§9) deferred — needs a generated bar PNG. |
| 7 | GTK theme | ✅ **VERIFIED in VM (2026-06-27)** | Chrome loads fully dark (charcoal window + cards), matches the desktop via `xdg-desktop-portal-kde`. Real Chrome, not a snap stub. (Pure-GTK GIMP/Inkscape not separately tested.) |
| 8 | Icons + cursor recolor | ✅ **VERIFIED in VM (2026-06-27)** | Papirus folder → saffron recolor (branding `postinst`). VM Dolphin shows all folders saffron + accent free-space bar. Cursor `Breeze`/24px (a *saffron* cursor needs binary assets — deferred). |
| 9 | Panel/layout polish | ⚠️ **floating did NOT apply (VM 2026-06-27)** | `floating=1` under `[Containments][2][General]` was the wrong key — VM panel is still full-width edge-to-edge. Need the correct Plasma 5.27 floating key. Calendar toast not seen at 110s (inconclusive). |
| 10 | Welcome app UI | ✅ **VERIFIED in VM (2026-06-27, after fixes)** | Renders perfectly: charcoal bg, saffron emblem, Inter title/body, single saffron CTA, token page-dots. Needed 3 fixes (see Known bugs #5): `qmlscene` pkg, `QT_SELECT=qt5`, `onAccent`→`accentInk` rename. |
| 11 | Calamares slideshow | 🟡 **token-aligned, needs verify** | `show.qml` retoned (charcoal bg, ink titles + saffron underline rule, secondary body, Inter) and `branding.desc` (charcoal sidebar). Was off-palette indigo with accent headings. |

Legend: ✅ done · 🟡 exists, needs token pass · ⚠️ authored, unverified · ❌ not started

---

## Known bugs to fix

1. **Wallpaper not applying on live boot** — desktop falls back to a mountain photo. **DIAGNOSED in VM (2026-06-26):** the wallpaper files *are* present (`/usr/share/backgrounds/dyuti/dyuti-default|light|lockscreen.svg`), and `widgetStyle=kvantum` + `Icons=Papirus-Dark` *are* correctly applied — but the **live user's** `plasma-org.kde.plasma.desktop-appletsrc` has **no `Image=`** for `org.kde.image`, while our `/etc/skel` copy does. So Plasma **regenerated the desktop containment on first run and dropped our pre-seeded wallpaper** (known Plasma behavior — a hand-written `appletsrc` is not reliably honored). The skel `appletsrc` and `layout.js` are both being ignored for the wallpaper.
   **FIX IMPLEMENTED (2026-06-27, awaiting VM verify):** stopped relying on the pre-seeded `appletsrc`. Added a dedicated **first-login autostart** (phase 1) that force-applies the wallpaper through the *running* shell:
   - `usr/bin/dyuti-firstboot-theme` — retries `plasma-apply-wallpaperimage .../dyuti-default.svg` until plasmashell's D-Bus is up (probe = the command's own exit code, ~30s budget), sets the lock screen via `kwriteconfig5 --file kscreenlockerrc ...`, and only writes its `~/.config/dyuti/.wallpaper-applied` marker once the desktop apply actually succeeds (so it retries next login if it didn't).
   - `etc/skel/.config/autostart/dyuti-firstboot-theme.desktop` — `NoDisplay=true`, `X-KDE-autostart-phase=1`, separate from `dyuti-welcome` so theme survives even if Welcome fails.
   Look-and-feel `defaultWallpaperTheme=dyuti` + `appletsrc Image=` left in place as the first-try path. **Belt-and-braces still TODO if SVG render proves flaky at login:** pre-render SVGs → 4K PNG at build time and point at the PNG (QtSvg rendering as a secondary suspect).
2. **"Widget Removed: Calendar"** notification on first boot — a panel applet (digital clock/calendar) errors out. **STILL OPEN (2026-06-27):** not fixed this session — root cause can't be pinned without a VM screenshot of the exact failing widget. Likely the same fragility class as the wallpaper bug (Plasma reconciling our hand-written `appletsrc` against its auto-generated default). **Next:** in the batched build, screenshot the toast, then decide between (a) giving the systemtray a proper containment block, or (b) seeding the panel via the look-and-feel `layout.js` instead of skel `appletsrc`.
3. ~~**Dolphin free-space bar renders green**~~ — **RESOLVED (VM 2026-06-27):** now renders saffron.
4. **Chrome present despite incremental skip** — the cached chroot still has Chrome from earlier full builds; a clean full build will exercise the new `gpg --dearmor` fix.
5. **Welcome app wouldn't launch — RESOLVED (VM 2026-06-27).** Three stacked problems, all fixed:
   - **(a) No QML runtime binary.** We listed `qtdeclarative5-dev-tools` expecting `qmlscene`, but **noble split `qmlscene` into its own package** — `dpkg -L qtdeclarative5-dev-tools | grep qmlscene` is empty. The `qmlscene`/`qml` names in `$PATH` are just qtchooser wrappers pointing at non-existent `/usr/lib/qt5/bin/qmlscene`. **Fix:** `apps.list` now ships the standalone `qmlscene` package.
   - **(b) Empty qtchooser default.** Even with the binary, `qmlscene` failed with *"could not find a Qt installation of ''"*. **Fix:** `dyuti-welcome` now `export QT_SELECT=qt5`.
   - **(c) QML signal-handler clash.** `Welcome.qml:31 Cannot assign a value to a signal` — the token property `onAccent` (name starting with `on`+capital) is parsed as a signal handler. **Fix:** renamed `onAccent`→`accentInk` in **both** `Welcome.qml` and SDDM `Main.qml` (same latent bug).
   Verified live: with all three applied, the Welcome app renders perfectly to tokens. **NOTE:** the `qmlscene` package lands in the *desktop* stage, so the next build must include the `desktop` target, not just `branding`.

---

## Light theme (added 2026-06-27)

A full **light variant** now ships alongside the default dark theme, built the
same way (single source of truth = `design-tokens.md` §2 light palette):

- **Plasma color scheme** — `usr/share/color-schemes/DyutiLight.colors` (crisp
  grey-white surfaces, same saffron accent + selection as dark).
- **Kvantum theme** — `usr/share/Kvantum/DyutiLight/{DyutiLight.kvconfig,DyutiLight.svg}`.
  `tools/gen-kvantum-svg.py` is now theme-parametric: one element set, two
  palettes, emits **both** `Dyuti.svg` (dark, byte-identical to before) and
  `DyutiLight.svg` (light).
- **GTK 3 + 4** — canonical variants in `usr/share/dyuti-theme/gtk{3,4}-{dark,light}.css`.
- **Wallpaper** — `usr/share/backgrounds/dyuti/dyuti-light.svg` redrawn ("Dawn":
  the matched light sibling of the charcoal default — same low-right saffron
  radiance, inverted onto a neutral grey-white field with layered ribbons).
- **Switcher** — `usr/bin/dyuti-theme [dark|light|toggle]` flips color scheme +
  Kvantum + icons (Papirus / Papirus-Dark) + GTK css/settings + wallpaper/lock in
  one go; menu launcher `usr/share/applications/dyuti-theme-toggle.desktop`.

**Light is now the shipped desktop default (2026-06-27).** Flipped every
session-level pin to light: skel `kdeglobals` (`ColorScheme=DyutiLight`,
`Icons=Papirus`), skel `Kvantum/kvantum.kvconfig` (`theme=DyutiLight`), skel
`gtk-{3,4}.0/{gtk.css,settings.ini}` (light + `prefer-dark=false` + `Breeze`),
skel `appletsrc` wallpaper, `dyuti-firstboot-theme` (light wallpaper + lock), and
the look-and-feel `defaults`. Dark is one command away: `dyuti-theme dark`.
**SDDM greeter + Plymouth boot stay dark by design** (Plymouth is dark-only per
tokens §9; flip those separately if a fully-light boot/login is wanted).

**Needs VM verify:** first login lands on the light desktop (wallpaper + light
widgets), `DyutiLight` shows in System Settings → Colors / Kvantum Manager, and
`dyuti-theme dark` flips back cleanly.

---

## Verify-and-fix loop (the method)

For each deliverable: **build → boot VM → screenshot the specific surface → judge vs north-star → fix → rebuild.**

Order to verify (highest perceived-quality first):
1. Wallpaper applies (desktop) ← currently blocking first impression
2. Panel/layout looks floating + premium, no widget errors
3. SDDM login screen (reboot to greeter or `sddm-greeter --test-mode`)
4. Plymouth boot splash
5. Welcome app first-run
6. GTK apps (Chrome/GIMP) match the dark theme
7. Calamares installer slideshow
8. Cohesion pass across all

---

## Tooling / workflow gotchas (don't relearn these)

- **Build:** edit on Windows `D:\projects\dyuti-os`; build in WSL at `/root/dyuti-os`. Use `tools/wsl-resync-build.sh` (file-based — never inline `$vars` through `wsl bash -lc`, they expand to empty). Invoke: `wsl -d Ubuntu-24.04 -u root -- bash -lc 'sed "s/\r//" /mnt/d/projects/dyuti-os/tools/wsl-resync-build.sh > /tmp/rb.sh && bash /tmp/rb.sh <targets>'`. Targets default to `desktop branding cleanup iso`; pass `branding cleanup iso` to skip desktop.
- **Branding must reinstall:** `40-branding.sh` now uses `dpkg -i` (apt skips same-version 0.1, leaving stale files).
- **Base is Plasma 5.27 / Qt5** (noble) → `qt5-style-kvantum` is correct; `qt6-style-kvantum` doesn't exist in noble.
- **VM test:** `wsl --shutdown` first (free host RAM), copy ISO → `dist-test/dyuti-fixed.iso`, re-attach with `closemedium` (overwriting same path leaves a stale UUID), `startvm Dyuti`. Drive with `VBoxManage controlvm Dyuti keyboardputstring/keyboardputscancode` + `screenshotpng`. KRunner = Alt+F2 (`38 3c bc b8`), Enter = `1c 9c`. **Don't Alt+F4 on the bare desktop** — it triggers leave/logout and powered the VM off once.

## Build/workflow fixes already landed this session
- `chroot/install-desktop.sh` — Chrome `gpg --dearmor` no longer hangs in background builds.
- `build/stages/40-branding.sh` — `dpkg -i` so branding actually reinstalls.
- `config/package-lists/look.list` — corrected to `qt5-style-kvantum`.
- `tools/gen-kvantum-svg.py` — regenerates `Dyuti.svg` from tokens.
- `tools/wsl-resync-build.sh` — resync + incremental build helper.

---

## Where we are now (2026-06-27)

**All 11 deliverables are authored and token-aligned.** Every off-palette indigo
remnant has been retoned to the charcoal+saffron tokens. Nothing left to *design*
in the first-run journey — the remaining work is **verification** and two
asset-dependent polish items.

### Authored this session (awaiting VM verify)
- #1 wallpaper force-apply autostart (`dyuti-firstboot-theme`)
- #6 Plymouth retoned (charcoal + saffron spinner)
- #8 Papirus saffron folder recolor (`configure-icons.sh`) + Breeze cursor
- #9 floating panel (`floating=1`)
- #10 Welcome.qml retoned (charcoal, Inter scale, single saffron CTA)
- #11 Calamares retoned (`show.qml` + `branding.desc`)
- #4 look-and-feel metadata description fixed
- #5 SDDM / #7 GTK audited → confirmed token-correct (no edits needed)

### Deferred — need binary assets (not blocking)
- True 1px Plymouth progress hairline (§9) — needs a generated bar PNG.
- Saffron cursor — needs a custom cursor theme (binary). Breeze ships meanwhile.

### Still open — needs the VM to diagnose
- #9 "Widget Removed: Calendar" first-boot toast (see "Known bugs" #2).

## Next session — VERIFY ONE BY ONE (build first, then walk the journey)
Build once (`tools/wsl-resync-build.sh`), boot the Dyuti VM, and screenshot each
surface against the north star, in perceived-quality order:
1. Desktop wallpaper applies on first login (+ lock screen) — #1
2. Floating panel + capture the Calendar toast — #9
3. Saffron Papirus folders in Dolphin/desktop — #8
4. SDDM login screen (reboot to greeter) — #5
5. Plymouth boot splash — #6
6. Welcome app first-run — #10
7. GTK apps (Chrome/GIMP) match dark theme — #7
8. Calamares installer slideshow — #11
9. Cohesion pass across all surfaces.
