# Dyuti OS — UI Polish Plan

> Full product spec lives in [`docs/00-SPECIFICATION.md`](docs/00-SPECIFICATION.md).
> This file = the **active near-term task list**. Status snapshot below.

---

## Where we stand (snapshot — 2026-06)

**✅ Done — the "credible premium Linux desktop" base (≈Zorin visual parity):**
build pipeline, KDE Plasma base, `dyuti-branding` deb, light/dark schemes,
design tokens; desktop shell, footer/panel, launcher, taskbar, window manager,
lock screen, clipboard; boot (Plymouth), login (SDDM), installer (Calamares),
welcome app, updates (Discover+fwupd), driver manager, firewall; full core apps
(Files, Terminal, Calc, PDF, media, screenshot, archive); branding (icons,
wallpapers, fonts); KDE Connect; **Alpha ISO built** (`dyuti-0.1-alpha`).

**◐ Partial / shipped-but-not-integrated:** virtual desktops (default 1),
context menus (too wide), Indic fonts+input (no gov services yet), Timeshift
(no recovery UX), quick-settings/notifications (stock Plasma).

**❌ Not started — the differentiators (the real moat, ~0%):**
`india/` gov services (DigiLocker, UPI, UMANG, Aadhaar, ABHA, GST · **P0**),
`ai/` (assistant, OCR, translation), `cloud/` (Dyuti-ID, Sync, Device-Link),
`enterprise/` (device mgmt, kiosk, LDAP, policy · **P0 for govt**), custom
Settings app, custom Store, `gaming/`, `developer/` SDK & APIs, inline search,
webcam app.

**One-liner:** base layer is essentially done and being polished (the 6 tasks
below); the India-first / AI / cloud / enterprise layers that make Dyuti *Dyuti*
are not yet started — and that's the bulk of the roadmap weight.

**Recommended sequencing:** ship the 6 polish tasks → write Core specs
(`00-VISION`→`04-TOKENS`) → scaffold + build the `india/` layer (the moat).

---


All UI customization ships through the **`dyuti-branding` .deb** under
`branding/dyuti-branding/`. After editing, rebuild with **`sudo make refresh`**
(incremental: reuses the chroot, re-brands, repacks the ISO) and test the ISO in
a VM. Verification for every task = boot the refreshed ISO and eyeball it.

Current relevant facts:
- Widget style is **Breeze**, driven live by the `DyutiLight` / `Dyuti` color
  schemes (`branding/.../usr/share/color-schemes/`). Kvantum themes are shipped
  but **not active**, so Kvantum-only tweaks have no effect on the default look.
- Footer = floating bottom panel defined in
  `etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc`.
- Defaults set in `etc/skel/.config/kdeglobals` and `kwinrc`.

---

## Priority tasks (do these first, one by one)

### 1. Footer — grayer in light theme so icons stay visible
**Problem:** the floating panel is near-white (`Colors:Window` BackgroundNormal =
`238,241,245`), so light/desktop icons on it look washed out and the panel has no
edge definition.

**Approach (recommended → fallback):**
- **A (proper, targeted):** ship a minimal custom Plasma **desktop theme** that
  overrides *only* the panel background to a soft Windows‑11 gray
  (~`228,231,238` / `#E4E7EC`), inheriting Breeze for everything else. New dir:
  `usr/share/plasma/desktoptheme/Dyuti/` with a `metadata.json`,
  `colors`, and `widgets/panel-background.svg(z)`; point the look‑and‑feel
  `defaults` at it. Cleanest result, panel-only, doesn't touch windows.
- **B (quick win):** nudge `[Colors:Window] BackgroundNormal` in
  `DyutiLight.colors` from `238,241,245` → ~`226,230,236`. One-line change, but
  it also grays all window chrome (often acceptable / Win11-like).

**Files:** `usr/share/color-schemes/DyutiLight.colors`, optionally new
`usr/share/plasma/desktoptheme/Dyuti/*` + look-and-feel `defaults`.
**Verify:** light theme — panel reads as a distinct light-gray bar; tray/clock/
task icons clearly visible.

### 2. Context menu — too wide
**Problem:** right-click menus render wider than wanted. The narrow Kvantum menu
metrics from the last patch don't apply because the active style is Breeze.

**Approach:**
1. **Reproduce in VM** and note *which* menu (desktop right-click = Plasma theme;
   app/Dolphin right-click = Breeze widget style) — the fix differs per case.
2. App menus (Breeze): width is content-driven. Levers: drop `menuFont` size a
   point in `kdeglobals` ([General] `menuFont=Inter,9,...`), and trim any long
   custom action labels we add. Breeze has no direct width knob.
3. Plasma/desktop menu: governed by the desktop theme metrics (ties into task 1's
   custom theme if we ship one).

**Files:** `etc/skel/.config/kdeglobals` (and the task‑1 desktop theme if used).
**Verify:** context menus are compact, no excess horizontal padding.

### 3. Integrate webcam
**Problem:** no webcam/camera app is installed (`kamoso`/`cheese` absent).
**Approach:** add **`kamoso`** (KDE-native, matches Plasma look) to
`config/package-lists/multimedia.list` (or `apps.list`). Pulls in V4L stack.
Confirm `v4l-utils` present for diagnostics; webcams generally work via
`uvcvideo` in-kernel, no extra driver needed.
**Files:** `config/package-lists/multimedia.list`.
**Note:** adding a package needs the package stage, not just `refresh` — run
`sudo make desktop` (or a full `make build`) so the chroot picks it up, then
`make iso`.
**Verify:** Kamoso launches and shows the camera feed in the VM (needs a webcam
passed through to the VM).

### 4. Remove the "+" selection marker on folder hover
**Problem:** hovering a folder/file shows a "+" selection toggle.
**Approach:** ship a Dolphin default that disables it. Create
`branding/dyuti-branding/etc/skel/.config/dolphinrc` with:
```
[General]
ShowSelectionToggle=false
```
If the "+" the user means is on the **desktop Folder View** (not Dolphin),
that's the Plasma folder applet — verify in VM; it has no clean config key and
may need an applet-config tweak in `appletsrc`. Confirm target before coding.
**Files:** new `etc/skel/.config/dolphinrc` (+ maybe `appletsrc`).
**Verify:** hovering items no longer shows the "+" toggle.

### 5. Multiple desktops (enable the built-in feature)
**Problem:** KDE Plasma already ships virtual desktops — we just default to **one**
(no `[Desktops]` section in `kwinrc`). Nothing custom to build; just turn on and
configure the existing feature, the way Ubuntu/GNOME exposes Workspaces.
**Approach:**
1. Add a `[Desktops]` block to
   `etc/skel/.config/kwinrc` — e.g. 4 desktops, one row:
   ```
   [Desktops]
   Number=4
   Rows=1
   ```
2. Add a **Pager** widget to the footer in `appletsrc` so desktops are visible/
   switchable (sits well next to the system tray).
3. Confirm the switch UX: built-in **Overview**/Desktop-Grid effect + default
   shortcuts (Meta+Tab, Ctrl+F1..F4) already exist — just verify they're on.
**Files:** `etc/skel/.config/kwinrc`, `appletsrc` (Pager widget).
**Verify:** 4 workspaces present, pager shows them, shortcuts switch between them.

### 6. Inline search box in the footer (Windows 11-style)
**Reality check:** Plasma has **no built-in inline panel search widget**. Its
search (KRunner / Kickoff) opens *over* the screen, not embedded in the taskbar.
So unlike tasks 1–5, this can't be done with config alone — it needs a **search
plasmoid** placed in the panel. This is the heaviest task here.
**Options (pick one):**
- **A — ship a third-party plasmoid** (e.g. a maintained "panel search"/KRunner
  applet from the KDE store). Fastest to working, but adds a dependency we must
  vendor into the branding package and keep updated.
- **B — write a tiny custom plasmoid:** a QML search field that forwards the
  query to KRunner/Milou. Most control + on-brand, but real QML work + testing.
- **C — approximate:** put a Kickoff/launcher button styled as a search pill that
  opens straight into its search field. Cheapest, but it opens a menu, not a true
  inline box — least like Win11.
**Recommendation:** start with **C** to validate the look in the panel, then
decide if **A/B** is worth it.
**Files:** `appletsrc` (placement) + new plasmoid under
`usr/share/plasma/plasmoids/` if A/B.
**Note:** A/B add files/deps → likely **not** in the cheap `make refresh` batch;
budget a separate build + iteration pass.
**Verify:** a search field sits inline in the footer; typing returns app/file
results.

---

## Backlog (planned earlier, schedule after the priority tasks)

- **Weather on user location:** the weather applet is shipped but needs a default
  + auto-locate. Plasma's weather applet has no IP geolocation; plan a firstboot
  helper to set the station from locale/geo-IP, written into `appletsrc`.
- **Reduce animations (lighter, simpler feel):** lower `AnimationDurationFactor`
  in `kdeglobals` (currently `0.875` → ~`0.5`) and trim KWin effects in
  `kwinrc` (disable wobbly/heavy effects). Quick, low-risk.
- **Language support:** review `config/package-lists/languages.list`; ensure
  language packs + input methods (e.g. `ibus`/`fcitx` for Indic) and a
  first-run language picker.
- **Feature audit:** walk the README/docs feature list vs. what's actually in the
  ISO and record what's still missing (separate pass).

---

## Workflow reminder
1. Edit files under `branding/dyuti-branding/` (or `config/package-lists/`).
2. `sudo make refresh` for branding/theme changes; `sudo make desktop` + `make
   iso` when a **new package** is added.
3. Boot `dist/*.iso` in a VM and verify.
4. Commit per task with a focused message.
