# Dyuti OS — Unified Theme Architecture (De-Breeze + De-Duplicate)

> **Why this exists.** Today Dyuti is *half Dyuti, half Breeze*, and every
> "ours" asset is hand-built **twice** (light + dark). This plan consolidates
> everything into **one token-derived Dyuti theme identity** where light/dark
> are two *outputs of one source*, and Breeze is only an upstream fallback —
> never the visible default.
>
> Companion to [`DESIGN-SYSTEM.md`](DESIGN-SYSTEM.md) (Phases 6 + 14) and
> [`design-tokens.md`](design-tokens.md) (token values). Base is Plasma 5.27 /
> Qt5 (noble).
>
> Last updated: 2026-06-27.

---

## 1. The two problems

**Problem A — we lean on Breeze for the most visible layers.**

| Layer | Controls | Today | Verdict |
|---|---|---|---|
| Color scheme | app colors | ✅ Dyuti / DyutiLight | ours |
| Kvantum | Qt widget shapes | ✅ Dyuti / DyutiLight | ours |
| **Plasma desktop theme** | **panel, launcher, tray, notifications, tooltips** | ❌ Breeze | **must replace** |
| **Window decoration** | titlebar + buttons | ❌ Breeze, unconfigured | **must configure** |
| GTK theme | GTK app chrome | ⚠️ Breeze-gtk + our CSS | acceptable bridge |
| Cursor | pointer | ❌ Breeze | deferred (binary asset) |
| Icons | icons | ⚠️ Tela (third-party) | interim, OK |

The **Plasma desktop theme** is the worst offender: the shell (panel/launcher/
tray/notifications) is literally Breeze. That is the single biggest reason the
desktop doesn't read as one product.

**Problem B — "two two": every asset is duplicated by hand.**

`Dyuti.colors` + `DyutiLight.colors`, two Kvantum SVGs, `gtk-dark.css` +
`gtk-light.css`, two wallpapers — each maintained separately. Change one token
and you must edit both; they drift. The brief forbids this.

---

## 2. Target architecture

**One source → generators → all assets → one Look-and-Feel. Breeze = fallback.**

```
docs/design-tokens.md            (human source of truth: values)
        │  exported to
        ▼
tools/tokens.json                (ONE machine source: light + dark value sets)
        │  build-time generators (tools/gen-*.py)
        ├─► usr/share/color-schemes/Dyuti.colors   + DyutiLight.colors
        ├─► usr/share/Kvantum/Dyuti/…              + DyutiLight/…
        ├─► usr/share/plasma/desktoptheme/Dyuti/…  ← NEW (replaces Breeze shell)
        ├─► usr/share/dyuti-theme/gtk3.css/gtk4.css (dark+light)
        ├─► etc/skel/.config/{kwinrc,breezerc}      (window-deco config)
        └─► etc/skel/.config/{kdeglobals,plasmarc,kvantum.kvconfig}
        ▼
usr/share/plasma/look-and-feel/in.dyuti.lookandfeel   ← bundles ALL of the above
        ▼
Breeze / Breeze-gtk / breeze_cursors  = dependency + fallback ONLY
```

**Principles**
- **One token source.** No hand value lives in two files. A token change
  regenerates *both* themes.
- **One theme identity.** `Dyuti` is the name everywhere a name is set
  (color scheme, desktoptheme, look-and-feel, Kvantum).
- **Light/dark = variants, not duplicates.** Generators emit both from the same
  template; only the value set differs.
- **Breeze stays installed** (apps may reference it), but is never the *selected*
  default for any visible layer except as a graceful fallback.

---

## 3. Work breakdown

### Step 1 — Token source + generators (kills duplication) — *Problem B*

**Goal.** A single `tokens.json` and a generator per asset so light/dark are
generated, not hand-written.

**Files.**
- `tools/tokens.json` *(new)* — `{ "light": {...}, "dark": {...}, "accent": {...}, "radius": {...}, "motion": {...}, "type": {...} }`, transcribed from `design-tokens.md`.
- `tools/gen-colorscheme.py` *(new)* — emits `Dyuti.colors` + `DyutiLight.colors`.
- `tools/gen-kvantum-svg.py` *(exists — already theme-parametric)* — read from `tokens.json`.
- `tools/gen-gtk-css.py` *(new)* — emits `gtk3/4` dark+light.
- `tools/gen-desktoptheme.py` *(new)* — emits the desktoptheme `colors` + recolors SVGs.

**Implementation.** Each generator reads `tokens.json`, loops `["light","dark"]`,
writes both artifacts. A `make tokens` target regenerates everything; CI asserts
the working tree is unchanged after regen (proves nothing is hand-edited).

**Acceptance.**
- [ ] Edit one value in `tokens.json` → `make tokens` → both themes update, no manual edits.
- [ ] `git diff` after regen on a clean tree = empty.

---

### Step 2 — `desktoptheme/Dyuti` (kills the Breeze shell) — *Problem A, #1*

**Goal.** Replace Breeze as the Plasma *shell* theme: panel, launcher
background, popups, system tray, tooltips, notifications.

**Files & KDE location.**
- `branding/.../usr/share/plasma/desktoptheme/Dyuti/`
  - `metadata.json` (Id `Dyuti`, follows color scheme)
  - `colors` (from tokens)
  - `widgets/*.svgz` (panel-background, background, tooltip, tabbar, listitem, button, etc.)
  - `dialogs/*.svgz` (background, shutdowndialog)
  - `icons/*.svgz` (system tray monochrome set)
- `etc/skel/.config/plasmarc` → `[Theme] name=Dyuti`.

**Implementation.**
- Start from Breeze's SVG structure (same element names) so Plasma finds every
  required part, then recolor/reshape to tokens: radius `12`, `popup-bg`/
  `panel-bg` alpha+blur, shadow `elev-3`.
- Keep node counts low; ship `.svgz` (gzipped). This theme renders constantly —
  optimize hardest here.
- The theme's `colors` follows the active color scheme so Plasmoids match Qt apps
  in both light and dark from one theme (no separate dark desktoptheme needed).

**Acceptance.**
- [ ] `plasmarc` selects Dyuti; panel/launcher/tray/tooltips visibly ours.
- [ ] Same radius/shadow/color as Kvantum (Qt) and GTK apps at a glance.
- [ ] Light and dark both correct from the single theme.

---

### Step 3 — Window decoration config (configure Breeze, don't replace) — *Problem A, #2*

**Goal.** Minimal Dyuti titlebar using the **native Breeze decoration engine**
(fast C++), just configured — no Aurorae/QML (slow).

**Files.**
- `etc/skel/.config/kwinrc` `[org.kde.kdecoration2]` — `library=org.kde.breeze`, `ButtonsOnRight=IAX`/`HIAX`, `BorderSize=None`.
- `etc/skel/.config/breezerc` — `DrawBackgroundGradient=false`, `DrawTitleBarSeparator=false`, titlebar size, hover.

**Implementation.** Titlebar ≈ `36px`, buttons right, no gradient/separator,
depth via `elev-2` shadow, accent only on close-hover.

**Acceptance.**
- [ ] Titlebars minimal + consistent; active/inactive clear; no double borders when tiled.

---

### Step 4 — GTK identity (rebrand the bridge) — *Problem A, low priority*

**Goal.** Stop *calling* the theme "Breeze" in our config even though we use the
breeze-gtk bridge for color mapping.

**Files.**
- `usr/share/themes/Dyuti/` *(new, thin)* — a Dyuti-named GTK theme that wraps/derives breeze-gtk + our `@define-color` overrides from tokens.
- Update `dyuti-theme` + skel `settings.ini` `gtk-theme-name=Dyuti` (currently `Breeze`).

**Implementation.** Generated by `gen-gtk-css.py`. Mechanism stays breeze-gtk
(maps KDE colors to GTK), but the visible name and colors are Dyuti.

**Acceptance.**
- [ ] GTK apps report theme "Dyuti"; colors match the desktop in both modes.

---

### Step 5 — Cursor + icon identity (north star, deferred) — *Problem A, cosmetic*

- Cursor: ship a Dyuti cursor theme (needs binary assets) — deferred; `breeze_cursors` meanwhile.
- Icons: converge on Tela-orange now; build a small **Dyuti symbolic core** (~120 visible icons) inheriting Tela/Papirus later (DESIGN-SYSTEM Phase 4).

---

### Step 6 — Bundle into ONE Look-and-Feel — *the glue*

**Goal.** `in.dyuti.lookandfeel` selects every Dyuti layer in one switch, so
"Dyuti" is a single Global Theme in System Settings → Appearance.

**Files.**
- `usr/share/plasma/look-and-feel/in.dyuti.lookandfeel/contents/defaults` — point at: color scheme `DyutiLight`/`Dyuti`, `desktoptheme=Dyuti`, `widgetStyle=kvantum`, `Icons=Tela-orange`, decoration `org.kde.breeze` (configured), cursor, wallpaper.
- `dyuti-theme [dark|light|toggle]` — runtime switch flips the *value set*, not the theme identity.

**Acceptance.**
- [ ] Selecting the Dyuti Global Theme sets all layers at once.
- [ ] `dyuti-theme toggle` flips light↔dark with zero remnants.

---

## 4. What stays Breeze (and why that's correct)

- **breeze-gtk** — a *bridge* that maps KDE colors into GTK; we keep the engine, rename/skin to Dyuti (Step 4). Replacing it wholesale buys nothing.
- **Breeze window-decoration engine** — native C++, fastest option; we *configure* it (Step 3) rather than ship a slow QML decoration.
- **Breeze as installed fallback** — apps/KCMs may reference Breeze assets; keep it present so nothing breaks if a Dyuti part is missing.

Everything else visible becomes Dyuti.

---

## 5. Sequencing (impact-ranked)

1. **Step 2 — `desktoptheme/Dyuti`** — biggest visible win; kills the Breeze shell.
2. **Step 1 — tokens.json + generators** — stops the duplication bleeding; every later step generates both themes for free.
3. **Step 3 — window-deco config** — cheap, on every window.
4. **Step 6 — bundle look-and-feel** — makes it one selectable product.
5. **Step 4 — GTK rebrand** — polish.
6. **Step 5 — cursor/icons** — deferred, needs assets.

## 6. Definition of done

- [ ] No visible layer selects "Breeze" by name (shell, deco-look, GTK name) — Breeze is fallback only.
- [ ] One `tokens.json` drives every asset; regen leaves a clean tree.
- [ ] Light/dark are generated variants, not hand-maintained files.
- [ ] Selecting the Dyuti Global Theme themes the *entire* desktop in one click.
- [ ] Verified in the Dyuti VM: panel, launcher, tray, notifications, titlebars, Qt apps, GTK apps all read as one Dyuti product, in both light and dark.
