# Dyuti OS — Design System & Theme Architecture

> **Status:** canonical plan. This is the production blueprint for the complete
> Dyuti desktop experience. It builds on (and does not replace)
> [`design-tokens.md`](design-tokens.md), which remains the single source of
> truth for token *values*. This document is the source of truth for
> *architecture, surfaces, phases, and acceptance*.
>
> Companion docs: [`design-tokens.md`](design-tokens.md) (token values),
> [`PLAN-WOW-PROGRESS.md`](PLAN-WOW-PROGRESS.md) (live verify tracker).
>
> Last updated: 2026-06-27.

---

## 0. Philosophy & locked decisions

**"Beautiful because it is simple."** Every pixel has a purpose. No visual
noise, no gratuitous animation, no gradients-everywhere, no blur-everywhere, no
clutter. The desktop must read as a *commercial* operating system — modern,
professional, calm, fast, native, premium — never "flashy," never "Linux hobby
project."

Dyuti must feel **more premium than Zorin / Windows 11 / Ubuntu** while being
**lighter and faster** than all three. Lightness is not a side effect we hope
for; it is an engineered, measured budget (Phase 15).

### Locked decisions (overridable, but this is what the plan assumes)

| Decision | Value | Rationale |
|---|---|---|
| **Default theme** | **Dyuti Light** (max polish) | Per brief. Dark is first-class but secondary. |
| **Accent** | **Saffron `#ff9d4d`**, identical in light & dark | Whole brand + icons already built on it; "Dyuti" = radiance. Single token `--dy-accent` → swap to blue is one line if ever wanted. |
| **Dark mode** | **Token-derived, minimal asset duplication** | Brief rule. See Phase 14 — assets parameterized from tokens, not hand-duplicated. |
| **Motion** | **Cap ≤150ms**, ~50% `AnimationDurationFactor`, reduced-motion = 0 | Brief: "reduce ~70%, instant feel." |
| **Radius** | **8 / 12 / 16 + pill** (one scale) | Brief: one consistent scale. |
| **Font** | **Inter** (UI) + **Fira Code** (mono), one family | Brief: one font family. |
| **Icons** | **One language** — converge on a single recolored set (Tela-orange now; a Dyuti-original symbolic set is the north star), no mixed packs in the *visible* surface | Brief: don't mix packs. |
| **Window deco** | **Configured Breeze (native C++)**, not Aurorae (QML/SVG) | Performance — native decoration is far cheaper than QML. |
| **Plasma shell theme** | **Custom Dyuti `desktoptheme`** (SVG) | Currently missing — this is what makes panel/launcher/notifications look like *us*. |

### Reconciled token deltas vs `design-tokens.md`

These are the only places this plan overrides the current tokens. Phase 1
folds them in.

- **Radius** → collapse `4/6/10/14/pill` to **`sm=8` (controls/menu items), `md=12` (cards/popovers/toolbars), `lg=16` (dialogs/modals/login), `pill=999` (toggles/badges/search/slider thumb)**. `xs=6` retained *only* for checkboxes/tags.
- **Motion** → **`micro=80` (state flips), `fast=120` (hover/focus/press), `enter=150` (menu/dialog/drawer enter)**. Nothing exceeds 150ms. `--dy-dur-base 200` and `--dy-dur-slow 320` are **removed**. Login reveal is the *only* sanctioned exception and is itself ≤150ms per element.
- **Accent in dark** → unchanged hex (already identical), satisfying "accent colors remain identical."

---

## How to read each phase

Every phase has: **Goals · Assets · Files & KDE locations · Implementation ·
Testing checklist · Performance · Mockups to create · Status**.

Status legend: ✅ done · 🟡 partial · ⚠️ authored-unverified · ❌ not started.

---

## Phase 1 — Design tokens

**Goals.** One reconciled, reusable token set: spacing, radius, elevation,
shadow, typography, opacity, motion, color, component sizes. Everything else in
the OS reads from here. No magic numbers anywhere downstream.

**Assets.** None (definitions only).

**Files & KDE locations.**
- `docs/design-tokens.md` — human source of truth (values).
- `branding/.../usr/share/dyuti-theme/tokens.json` *(new)* — machine-readable token export, consumed by build-time generators.
- `tools/gen-*.py` — generators read `tokens.json`.

**Implementation.**
- Apply the radius/motion deltas above into `design-tokens.md`.
- Add a **component-size** token block: control height (`32`), compact control (`28`), touch target min (`40`), icon sizes (`16/20/24/32/48`), panel thickness (`44`), titlebar height (`36`).
- Add **opacity** tokens: `disabled 0.38`, `hover-overlay` (already), `scrim` (already), `divider 1.0 on subtle color`.
- Emit `tokens.json` so Kvantum SVG, color schemes, GTK CSS, QML all derive from one place (kills duplication — Phase 14).

**Testing checklist.**
- [ ] Every value in shipped assets traces to a token (grep for stray hex).
- [ ] `tokens.json` round-trips: regenerating assets produces byte-identical output.

**Performance.** Tokens are free. The payoff is downstream: one optimized value set.

**Mockups to create.** Token sheet (swatches + scales) as a single reference PNG.

**Status.** 🟡 (tokens exist; need radius/motion reconcile, component-size block, `tokens.json`).

---

## Phase 2 — Color system

**Goals.** Dual-theme neutral ramps + semantic colors + one saffron accent, all
AA-contrast verified. Dark = dark gray (never pure black), low contrast,
comfortable. Light = soft white, warm gray surfaces, high readability, minimal
shadow.

**Assets.** Plasma color schemes; semantic swatches.

**Files & KDE locations.**
- `usr/share/color-schemes/DyutiLight.colors` (default), `Dyuti.colors` (dark) — `/usr/share/color-schemes/`.
- Generated from `tokens.json` via `tools/gen-colorscheme.py` *(new)*.

**Implementation.**
- Keep current ramps (`design-tokens.md §1–2`). Verify every fg/bg pair ≥ 4.5:1 (text) / 3:1 (large/UI).
- Map per the mapping table (`§10`): accent → `DecorationFocus`/`DecorationHover`/selection; semantic → `Foreground{Positive,Neutral,Negative,Active}`.

**Testing checklist.**
- [ ] WCAG AA on all text pairs (automated contrast script).
- [ ] Selection, focus, disabled all legible in both themes.
- [ ] Color-blind sim (deuter/prot/trit): accent vs semantic still distinguishable (Phase 15/accessibility).

**Performance.** `.colors` is a flat INI — zero cost.

**Mockups to create.** Side-by-side light/dark palette board with contrast ratios annotated.

**Status.** ✅ (schemes exist; add generator + contrast CI).

---

## Phase 3 — Typography

**Goals.** One family (Inter UI / Fira Code mono), optimized spacing, readable at
all DPI.

**Assets.** `fonts-inter`, `fonts-firacode` (already in `look.list`).

**Files & KDE locations.**
- `etc/skel/.config/kdeglobals` `[General] font / fixed / smallestReadableFont / menuFont / toolBarFont / activeFont`.
- Fontconfig: `usr/share/fontconfig/conf.avail/` for hinting/antialias defaults.

**Implementation.**
- Set all kdeglobals font slots to Inter at the type-scale sizes (`§4`).
- Mono → Fira Code. Enable `tnum` in system monitor / tables.
- Hinting `slight`, sub-pixel `rgb`, antialias on (match GTK settings.ini already shipped).

**Testing checklist.**
- [ ] 1×, 1.5×, 2× scaling stays crisp; no clipping in panel/menus.
- [ ] Fallback chain (Cantarell/Roboto/Noto) covers missing glyphs/scripts.

**Performance.** Subset Inter to Latin + needed scripts if ISO size matters; keep Noto for full coverage.

**Mockups to create.** Type-scale specimen (Display→Overline) light + dark.

**Status.** 🟡 (fonts shipped + GTK set; kdeglobals font slots need explicit pinning).

---

## Phase 4 — Icons

**Goals.** ONE icon language: rounded, minimal, modern, flat-with-subtle-depth.
Folders + places + apps + symbolic all read as one set. No mixed packs visible.

**Assets.** Tela-orange (interim, installed from source) → **Dyuti symbolic set** (north star).

**Files & KDE locations.**
- `/usr/share/icons/Tela-orange` (+ `-dark`) — interim default.
- `etc/skel/.config/kdeglobals [Icons] Theme=Tela-orange`.
- Future: `usr/share/icons/Dyuti/` — original symbolic + folder set inheriting Tela/Papirus for long-tail coverage.

**Implementation.**
- **Now:** Tela-orange (done) — covers folders + places (fixed the blue Home/Desktop mismatch). Papirus stays *fallback only* (not the visible default).
- **North star:** ship a small **Dyuti symbolic core** (the ~120 icons users actually see: places, actions, status, devices, mimetypes-common) drawn to tokens; `Inherits=Tela-orange,Papirus,hicolor` for the rest. This makes the *visible* surface a single Dyuti language without redrawing 3,000 icons.
- Symbolic icons inherit `text-secondary` at rest, `accent` when active (per `§10`).

**Testing checklist.**
- [ ] Dolphin places, system tray, settings sidebar, notifications all same visual language.
- [ ] No Breeze/Papirus icon leaking among Tela in common views.
- [ ] Monochrome symbolic icons legible on light *and* dark.

**Performance.** Prefer SVG; run `scour`/`svgo` on the Dyuti core. Build icon cache at install (`gtk-update-icon-cache`).

**Mockups to create.** Icon grid (places/actions/status/devices) at 22/24/48px, both themes.

**Status.** 🟡 (Tela-orange wired; Dyuti symbolic core not started).

---

## Phase 5 — Window decorations

**Goals.** Minimal titlebar, simple controls, consistent spacing, no
unnecessary borders. Native-fast.

**Assets.** Breeze decoration config (no custom Aurorae — perf).

**Files & KDE locations.**
- `etc/skel/.config/kwinrc [org.kde.kdecoration2]` — `library=org.kde.breeze`, button layout, `BorderSize=None`/`Tiny`.
- `etc/skel/.config/breezerc` — titlebar size, button hover, `DrawBackgroundGradient=false`, `DrawTitleBarSeparator=false`.

**Implementation.**
- Titlebar height ≈ `36` (titlebar token), buttons right (`min,max,close`), no menu/icon clutter on the left.
- No window gradient, no separator line, 1px-or-none border (depth via shadow token `elev-2`).
- Accent appears on close-hover only (subtle), never as a titlebar fill.

**Testing checklist.**
- [ ] Active vs inactive titlebar distinguishable but calm.
- [ ] Buttons hit-targets ≥ touch-min; consistent spacing.
- [ ] Maximized/tiled windows: no double borders.

**Performance.** Breeze decoration is native C++ — keep it. **Do not** ship an Aurorae/QML decoration (slow, GPU).

**Mockups to create.** Titlebar states: active/inactive/maximized, light + dark.

**Status.** ❌ (not started — currently stock Breeze defaults).

---

## Phase 6 — Plasma theme (shell)

**Goals.** A custom **Dyuti `desktoptheme`** — the SVGs that draw the panel,
launcher background, popups, system tray, tooltips, notifications. This is the
missing piece that makes the *shell* (not just apps) look like Dyuti.

**Assets.** SVG theme package (panel, dialogs, widgets, tooltip, icons-system).

**Files & KDE locations.**
- `usr/share/plasma/desktoptheme/Dyuti/` — `metadata.json`, `colors`, `widgets/*.svgz`, `dialogs/*.svgz`, `icons/*.svgz`.
- `etc/skel/.config/plasmarc [Theme] name=Dyuti`.

**Implementation.**
- Build from tokens: panel/popup backgrounds use `panel-bg`/`popup-bg` (alpha + blur), radius `12`, shadow `elev-3`.
- `colors` file inside the theme points at the same ramp (so Plasmoids match Qt apps).
- Keep SVGs minimal (few elements) → fast render, small cache.

**Testing checklist.**
- [ ] Panel, Kickoff, tray popups, tooltips all share corner radius, shadow, color.
- [ ] Matches Kvantum (Qt apps) and GTK apps at a glance.

**Performance.** `.svgz` (gzipped), minimal node count; this theme is rendered constantly — optimize hardest here.

**Mockups to create.** Panel + open launcher + tray popup composite, both themes.

**Status.** ❌ (**critical gap** — no custom desktoptheme today; shell is Breeze).

---

## Phase 7 — Launcher

**Goals.** Opens instantly. Simple search, pinned apps, recent apps, beautiful
spacing, minimal animation, no heavy effects.

**Assets.** Kickoff configuration + desktoptheme (Phase 6) styling.

**Files & KDE locations.**
- Applet config in `etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc` (Kickoff applet `[Configuration][General]`).
- Styling via Dyuti desktoptheme.

**Implementation.**
- Default to **Kickoff** (not Kickoff-grid/dashboard — lighter, calmer). Saffron logo as launcher icon (done).
- Generous row spacing (spacing tokens), pinned favorites pre-seeded (browser, files, settings, terminal, store).
- Search = instant KRunner backend; trim slow runners (disable web/units if perf-sensitive).
- Open/close animation ≤120ms fade, no zoom/scale.

**Testing checklist.**
- [ ] Open-to-typeable < 150ms on low-end HW.
- [ ] Search returns apps before 2nd keystroke.
- [ ] Spacing/legibility at 1× and 1.5×.

**Performance.** Disable unused KRunner plugins (`krunnerrc`). No blur beyond the one launcher surface.

**Mockups to create.** Launcher open with search results + favorites, both themes.

**Status.** 🟡 (stock Kickoff + logo; needs spacing/favorites/runner tuning + Phase-6 skin).

---

## Phase 8 — Panel

**Goals.** Slim, modern, consistent padding, beautiful tray, optional auto-hide,
zero clutter.

**Assets.** Panel containment config + desktoptheme panel SVG.

**Files & KDE locations.**
- `etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc` (`[Containments][2]`).
- Panel SVG from Dyuti desktoptheme.

**Implementation.**
- Thickness ≈ `44`; applets: launcher, task manager (icons-only), spacer, tray, clock, show-desktop (current order is good).
- **Resolve the floating-panel bug** (`PLAN-WOW-PROGRESS.md` #9): the correct Plasma 5.27 key is `[Containments][N] floating=1` **on the panel containment, not under `[General]`** — fix placement; verify in VM.
- Tray: curate visible items (network, volume, clipboard, battery), hide the rest.
- Auto-hide off by default (discoverability); expose a toggle in Welcome/Settings.

**Testing checklist.**
- [ ] Panel renders floating (gap from edges) with `elev-2` shadow.
- [ ] No "Widget Removed: Calendar" error (bug #2) — give systemtray + clock proper containment blocks.
- [ ] Tray icons monochrome, consistent.

**Performance.** Icons-only task manager (no live thumbnails by default). No panel blur if it costs frames on iGPU — fall back to opaque `0.96`.

**Mockups to create.** Panel detail (left/center/right) both themes.

**Status.** 🟡 (panel exists; floating + calendar-widget bugs open).

---

## Phase 9 — Widgets

**Goals.** A small set of well-styled, low-cost widgets. No JS-heavy plasmoids.

**Assets.** Curated default widgets + desktoptheme styling.

**Files & KDE locations.**
- Plasmoid configs in appletsrc; styling via Dyuti desktoptheme.

**Implementation.**
- Ship/skin only: digital clock, system tray, app launcher, task manager, (optional) a single calm system-monitor done in C++ widget — **not** a QML/JS monitor.
- Avoid analog-clock SVG animation, weather pollers, anything timer-driven on the desktop by default.

**Testing checklist.**
- [ ] Idle desktop CPU ~0% (no widget wakeups).
- [ ] Each widget matches radius/shadow/color tokens.

**Performance.** **This is a perf hotspot** — every default widget runs forever. Prefer static/native; ban polling widgets from defaults.

**Mockups to create.** Clock + tray + (optional monitor) detail.

**Status.** ❌ (defaults only; no curation/skin/perf pass).

---

## Phase 10 — Notifications

**Goals.** Compact, rounded, readable, minimal animation, intelligently grouped.

**Assets.** desktoptheme notification SVG + notify config.

**Files & KDE locations.**
- `etc/skel/.config/plasmanotifyrc` — grouping, popup position, timeout.
- Styling via Dyuti desktoptheme `dialogs/`.

**Implementation.**
- Radius `12`, `popup-bg` + `elev-3`, compact padding (spacing tokens).
- Group by app; popup timeout ~5s; position bottom-right (near tray).
- Slide/fade enter ≤150ms, no bounce.
- Accent only on action buttons / unread dot.

**Testing checklist.**
- [ ] 5 rapid notifications group, don't stack-spam.
- [ ] Readable over any wallpaper (blur/contrast).
- [ ] Do-not-disturb reachable.

**Performance.** Blur allowed here (it's transient + improves readability) — but cap radius; opaque fallback when no compositing.

**Mockups to create.** Single + grouped notification, both themes.

**Status.** ❌ (not started).

---

## Phase 11 — Settings app

**Goals.** Clean categories, large touch targets, simple navigation, modern
cards, no overload.

**Assets.** systemsettings styling (via Kvantum + color scheme + icons) + sidebar config.

**Files & KDE locations.**
- systemsettings inherits Qt theming (Kvantum/scheme) — mostly automatic.
- Default view: **sidebar (tree) view**, icon-only categories trimmed to essentials.
- KCM icons from Dyuti icon set.

**Implementation.**
- Card-style KCMs via Kvantum group-box radius `12`, `elev-1`.
- Trim/curate the most-used categories to the top (Appearance, Display, Network, Power, Users, About-Dyuti).
- Ship an **"About Dyuti"** KCM/page (brand, version, links) for the commercial feel.

**Testing checklist.**
- [ ] Touch targets ≥ `40`.
- [ ] Sidebar icons consistent; no Breeze leak.
- [ ] Search within settings works.

**Performance.** systemsettings is launched-on-demand — low priority for runtime budget; keep KCM list short to speed first paint.

**Mockups to create.** Settings home + one KCM (Appearance) both themes.

**Status.** ❌ (stock; inherits Kvantum but no curation/About page).

---

## Phase 12 — Login & Lock screen

**Goals.** Elegant, minimal, fast, wallpaper-backed; one small animation. Lock
screen consistent with login: readable clock, beautiful date, minimal blur.

**Assets.** SDDM theme (QML), kscreenlocker config.

**Files & KDE locations.**
- `usr/share/sddm/themes/dyuti/` — `Main.qml`, `theme.conf`, `Metadata.desktop`.
- `etc/sddm.conf.d/` — `Current=dyuti`.
- Lock: `etc/skel/.config/kscreenlockerrc`.

**Implementation.**
- Login card: `surface-3` + `radius-16` + `elev-4`, centered, Inter; saffron only on the login button fill + field focus ring.
- One reveal: card rises 16px + fades ≤150ms (per `§9`); reduced-motion → fade only.
- Lock screen reuses the card style; clock = Display type, date = Body-Large secondary; blur the wallpaper *lightly* only behind the clock/controls.
- **Fix the latent QML bug class** already found (`onAccent`→`accentInk`) — audit both Main.qml files.

**Testing checklist.**
- [ ] Greeter loads fast (no white flash; Plymouth→SDDM crossfade).
- [ ] Password field focus ring visible; caps-lock warning shows.
- [ ] Lock/unlock clock legible over wallpaper.

**Performance.** Keep QML node count low; avoid shaders. Pre-scale wallpaper for the greeter resolution.

**Mockups to create.** Login + lock, both themes (lock may stay dark by design).

**Status.** 🟡 (SDDM authored; needs reveal motion cap + lock styling + verify).

---

## Phase 13 — Wallpapers

**Goals.** Light + dark defaults, abstract + minimal, no noisy graphics.

**Assets.** Branded photo defaults + original abstract set + picker collection.

**Files & KDE locations.**
- `usr/share/backgrounds/dyuti/` — `dyuti-mountain.png` (light default), `dyuti-dark.png` (dark), original SVGs (`dyuti-light.svg`, `dyuti-default.svg`, `dyuti-bloom.svg`), `ATTRIBUTION.txt`.
- Picker: `plasma-workspace-wallpapers` + `ubuntu-wallpapers`.

**Implementation.**
- Default = branded Altai mountain with subtle neutral "Dyuti" wordmark (done).
- Keep one **abstract minimal** light + dark (the "Dawn"/SVG set) as alternatives.
- Pre-render any SVG default to PNG at build (QtSvg ignores blur filters).
- Ship matched light/dark pairs; keep saffron contained per `§3`.

**Testing checklist.**
- [ ] Default renders on first login (no fallback photo) — the PNG default removes the old QtSvg flakiness.
- [ ] Desktop icons readable over default (top-left negative space).
- [ ] Picker shows the full collection.

**Performance.** Optimize PNGs (`oxipng`); ship one 4K master, let Plasma downscale.

**Mockups to create.** Default desktop (icons + panel) over each wallpaper.

**Status.** ✅ (defaults shipped + branded + attributed; abstract set retained).

---

## Phase 14 — Dark mode adaptation

**Goals.** Dark auto-derives from shared tokens. **Minimal asset duplication.**

**Assets.** Generators, not duplicated hand-art.

**Files & KDE locations.**
- `tools/gen-colorscheme.py`, `tools/gen-kvantum-svg.py` (already theme-parametric), `tools/gen-gtk-css.py` *(new)* — all read `tokens.json`, emit both variants.
- Switcher: `usr/bin/dyuti-theme [dark|light|toggle]` (done).

**Implementation.**
- Treat dark/light as **two value sets feeding one generator**, not two artifacts maintained by hand. Today we hand-maintain `Dyuti.colors`+`DyutiLight.colors`, two Kvantum SVGs, two GTK CSS — migrate each behind a generator so a token change updates both.
- Accent identical across themes (already true).
- `dyuti-theme` flips scheme + Kvantum + icons (Tela-orange/-dark) + GTK + wallpaper in one shot (done) — keep it as the runtime switch; first-login applies via live shell (done).

**Testing checklist.**
- [ ] Change one token → regenerate → both themes update, no manual edits.
- [ ] `dyuti-theme toggle` flips every surface cleanly.
- [ ] No light remnants in dark (and vice-versa) after toggle.

**Performance.** Generation is build-time; runtime switch is a few `kwriteconfig5` calls + live D-Bus apply — cheap.

**Mockups to create.** Same screen light↔dark pair for 4 key surfaces.

**Status.** 🟡 (switcher + Kvantum generator done; colorscheme/GTK generators + de-duplication remain).

---

## Phase 15 — Optimization

**Goals.** Prove "fast & light." Near-zero added CPU at idle, low RAM, snappy
input. Motion reduced ~70%. SVGs/icons optimized. QML minimized.

**Assets.** Perf config + measurement scripts.

**Files & KDE locations.**
- `etc/skel/.config/kwinrc` + `kdeglobals [KDE] AnimationDurationFactor=0.5`.
- `etc/skel/.config/kwinrc [Plugins]` — disable: wobblywindows, glide/scale (use **Fade** only), blur (selectively), slideback, magiclamp; keep minimal.
- `etc/skel/.config/ksmserverrc` — no splash, restore "empty session" (faster login).
- `tools/perf-budget.sh` *(new)* — measures idle CPU, RAM, login time in VM.

**Implementation.**
- **Motion:** `AnimationDurationFactor=0.5`; window open/close = Fade ≤150ms; disable spring/wobble/zoom entirely. Honor global "reduce animations."
- **Compositing:** OpenGL 2.0/3.1, `LatencyPolicy` low; tear-free; allow disabling on very old GPUs.
- **Startup:** disable Baloo file indexing by default (or index-on-AC-only), trim autostart, no Akonadi unless PIM used.
- **Assets:** `svgo` all theme SVGs, `oxipng` wallpapers/PNGs, `.svgz` desktoptheme, subset Inter.
- **Memory:** target a leaner default than Kubuntu — measure idle RAM after login.

**Testing checklist (the proof).**
- [ ] Idle desktop CPU ≈ 0–1% (no busy widgets).
- [ ] Idle RAM after login measured + recorded vs Zorin/Kubuntu baseline.
- [ ] Cold login → usable desktop time recorded.
- [ ] Window switch/open feels instant (≤150ms, no jank) on 2-core/4GB VM.
- [ ] Reduced-motion setting kills all translation.

**Performance considerations.** This *is* the performance phase — it gates the
core promise. Numbers go in `PLAN-WOW-PROGRESS.md` with before/after.

**Mockups to create.** N/A — deliver a **benchmark table** instead (idle CPU/RAM, login time, vs competitors).

**Status.** ❌ (**critical gap** — motion/perf currently paper-only; this validates the whole pitch).

---

## Accessibility (cross-cutting — owned here, applied everywhere)

Not a phase number in the brief's list but a first-class requirement.

- **High-contrast scheme:** ship `DyutiHighContrast.colors`; expose in Appearance.
- **Color-blind safety:** verify accent vs semantic under deuter/prot/trit sim; never encode meaning by hue alone (pair with icon/shape).
- **Large cursor:** ship cursor at 24/32/48; expose size in Settings.
- **Keyboard navigation:** every default flow operable without mouse; visible focus ring (accent) on every control (token already mandates this).
- **Readable fonts:** Inter at sane minimum sizes; respect `smallestReadableFont`.

**Testing checklist.**
- [ ] Tab-through reaches all controls in launcher/settings/dialogs.
- [ ] High-contrast scheme passes AAA on body text.
- [ ] Color-blind sim: no information lost.

**Status.** ❌ (entirely missing today — highest-value untouched area after perf).

---

## Final pre-ISO polish checklist

Run this gate before any release build. Nothing ships red.

**Cohesion**
- [ ] Panel, launcher, Qt apps, GTK apps, notifications, settings share one radius, shadow, color, icon language.
- [ ] No Breeze/blue/indigo remnants anywhere (grep + visual sweep).
- [ ] Light is the default and fully polished; dark toggles cleanly with no remnants.

**Surfaces (each screenshotted vs north star)**
- [ ] Boot splash → SDDM crossfade (no flash to black).
- [ ] Login + lock legible, one reveal ≤150ms.
- [ ] Desktop: wallpaper applies first login, panel floats, no widget errors.
- [ ] Launcher opens instant, search fast, spacing right.
- [ ] Window decorations minimal/consistent; active vs inactive clear.
- [ ] Notifications compact, grouped, readable over wallpaper.
- [ ] Settings curated, cards consistent, About-Dyuti present.
- [ ] Dolphin + Chrome + a GTK app all match.

**Performance (recorded numbers, not vibes)**
- [ ] Idle CPU ≈ 0–1%; idle RAM recorded vs competitors.
- [ ] Cold-login-to-usable time recorded.
- [ ] Motion ≤150ms everywhere; reduced-motion works.
- [ ] No polling widgets in defaults; Baloo off/limited.

**Accessibility**
- [ ] High-contrast scheme present; keyboard nav complete; large cursor available; color-blind safe.

**Hygiene**
- [ ] All assets optimized (svgo/oxipng/svgz); Inter subset.
- [ ] Every asset value traces to a token (no stray hex).
- [ ] `ATTRIBUTION.txt` current; licenses clean.

---

## Priority order (what actually moves the needle)

Given limited time, this is the impact-ranked order — not the phase number order:

1. **Phase 15 motion/perf config** — *the* differentiator; currently paper-only, cheap to implement, huge perceived win.
2. **Phase 6 Dyuti desktoptheme** — makes the shell (panel/launcher/notifications) look like us, not Breeze.
3. **Phase 5 window decorations** — on every window; cheap (Breeze config).
4. **Phase 8 panel fixes** (floating + calendar bug) — visible, already half-done.
5. **Phase 10 notifications** + **Phase 7 launcher** tuning — high daily-touch surfaces.
6. **Accessibility** — high value, currently zero.
7. **Phase 14 de-duplication** (generators) — pays back every future change.
8. **Phase 4 Dyuti symbolic icon core** — last 10% of "belongs together."

Everything else (tokens, color, type, wallpapers) is already ✅/🟡 and just needs the reconcile pass in Phase 1–3.
