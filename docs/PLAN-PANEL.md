# Dyuti OS — Panel (Footer) Layout

> Windows 11-style bottom "footer" panel. Companion to
> [`DESIGN-SYSTEM.md`](DESIGN-SYSTEM.md) (Phases 8 Panel, 9 Widgets) and
> [`PLAN-UNIFY-THEME.md`](PLAN-UNIFY-THEME.md) (the Dyuti desktoptheme that skins
> this panel). Base: Plasma 5.27 / Qt5 (noble).
>
> Last updated: 2026-06-27.

---

## 1. Goal

Restructure the bottom panel to a calm, modern, Windows-11-style layout:
a left cluster (weather → Dyuti start → search), a flexible gap, app icons,
and the existing system tray + clock on the bottom-right.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ ☀ 24°  ◆ Dyuti  [ 🔍 Search apps & files ]   ← flex →   ▣ ▣ ▣ ▣   🌐 🔊 🔋 14:32 ▕│
└──────────────────────────────────────────────────────────────────────────────┘
 weather   start     inline search             spacer    app icons   tray    clock
```

Decision (locked): the search element is an **inline text field** (real box in
the panel), implemented as a **first-party Dyuti plasmoid** — not a third-party
dependency — so the whole panel stays one Dyuti product.

---

## 1a. Windows 11 reference (what we're matching)

Verified specs we borrow (sources below):

| Aspect | Windows 11 | Dyuti choice |
|---|---|---|
| Taskbar height | **48px** default (small 32 / large 72) at 100% DPI | **48px** panel thickness (was 44; aligned to Win11) |
| Icon render size | ~24px glyph in a 40–48px bar | 24px icons, 48px bar |
| Left corner | **Widgets button** = live weather + temperature | Weather applet, far left |
| Center | Start + Search + Task View + pinned/running, **centered** | We cluster left per your spec; spacer pushes app icons toward center-right (see note) |
| Search | inline **search box** left of center | inline Dyuti search box (§4) |
| Right (system tray) | hidden-icons chevron, network/volume/battery, **clock with date**, notification center | systemtray + clock(showDate) |
| Far-right corner | thin **show-desktop sliver** | `showdesktop` at far corner |
| Background | edge-to-edge, translucent (Mica/acrylic), rounded hover pills | Dyuti desktoptheme: translucent `panel-bg`, rounded hover (radius pill), optional float |
| Corners | not floating (edge-to-edge) | optional `floating=1` is *more* premium than Win11 — keep as Dyuti differentiator |

**Layout note.** Windows 11 *centers* the Start/search/app cluster. Your spec
puts weather → start → search on the **left**, then a gap, then app icons. We
follow your spec (left cluster + spacer). If you later want the Win11 *centered*
look, it's a one-line change: add a second expanding spacer before the weather
group so the middle block centers.

---

## 2. Applet map (left → right)

| # | Element | Plugin id | Package needed | Notes |
|---|---|---|---|---|
| 1 | Weather | `org.kde.plasma.weather` | **`kdeplasma-addons`** (add) | Polling widget — the one exception to "no pollers" (Phase 9). Default a sensible city; user-editable. |
| 2 | Dyuti start | `org.kde.plasma.kickoff` | (have) | `icon=dyuti-logo` (already set). |
| 3 | Inline search | **`org.dyuti.search`** (new, first-party) | shipped in branding | QML `TextField` → KRunner over D-Bus. See §4. |
| 4 | Flexible space | `org.kde.plasma.marginsseparator` | (have) | Pushes icons to center-right. |
| 5 | App icons | `org.kde.plasma.icontasks` | (have) | Pinned + running, icons-only (no live thumbnails by default — perf). |
| 6 | System tray | `org.kde.plasma.systemtray` | (have) | Curated visible items: network, volume, battery, clipboard. |
| 7 | Clock | `org.kde.plasma.digitalclock` | (have) | `showDate=true`. |
| 8 | Show desktop | `org.kde.plasma.showdesktop` | (have) | Tiny peek at the far bottom-right corner (Windows-style). |

Required package change: add **`kdeplasma-addons`** to `config/package-lists/desktop.list`
(provides the weather applet + other native widgets; it is *not* a polling-heavy
metapackage by itself — only the weather *instance* polls).

---

## 3. Panel containment (appletsrc)

Replace the panel containment in
`branding/.../etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc`
and the look-and-feel `layouts/org.kde.plasma.desktop-layout.js` with this order.

```ini
[Containments][2]
formfactor=2
location=4
plugin=org.kde.panel
floating=1            ; floating footer (verify the 5.27 key in VM — bug #9)

[Containments][2][General]
AppletOrder=10;3;11;5;4;6;7;8     ; weather;kickoff;search;spacer;icontasks;tray;clock;showdesktop

; 10 = weather   org.kde.plasma.weather
; 3  = kickoff   org.kde.plasma.kickoff  (icon=dyuti-logo)
; 11 = search    org.dyuti.search
; 5  = spacer    org.kde.plasma.marginsseparator   (expanding)
; 4  = icontasks org.kde.plasma.icontasks
; 6  = systemtray org.kde.plasma.systemtray
; 7  = digitalclock org.kde.plasma.digitalclock     (showDate=true)
; 8  = showdesktop org.kde.plasma.showdesktop
```

Thickness ≈ `48px` (panel-thickness token, aligned to Windows 11 default).
Padding consistent via the Dyuti desktoptheme panel SVG (PLAN-UNIFY-THEME Step 2).

---

## 4. First-party "Dyuti Search" plasmoid

**Why first-party.** Plasma has no native always-visible search field; the
community widgets are inconsistently maintained. A ~60-line QML plasmoid keeps
it ours, light, and guaranteed to load on 5.27.

**Files & KDE location.**
- `branding/.../usr/share/plasma/plasmoids/org.dyuti.search/`
  - `metadata.json` — `Id=org.dyuti.search`, `X-Plasma-API=declarativeappletscript`, category `Utilities`.
  - `contents/ui/main.qml` — a pill `TextField` (radius pill, `surface-2`, search icon), placeholder "Search apps & files".

**Behaviour.**
- On Enter / first keystroke, hand the query to KRunner via D-Bus:
  `org.kde.krunner /App org.kde.krunner.App.query "<text>"` (opens the KRunner
  overlay with results), then clear the field. This reuses KRunner's full search
  (apps, files, calculator, settings) — zero new search engine to maintain.
- Width ~280px; collapses to a search *icon* on narrow panels.
- Styling from tokens (consumes the desktoptheme), not hard-coded.

**Performance.** No timers, no polling — idle cost ≈ 0. Only active while typing.

---

## 5. Risks & gotchas

- **Unknown/typo'd plugin id ⇒ Plasma silently drops the applet** ("Widget
  Removed" toast — same class as bug #2). Every id above must be installed
  *before* the panel references it: `kdeplasma-addons` (weather) and the shipped
  `org.dyuti.search` must exist in the image, else those slots vanish.
- **Floating panel** (`floating=1`) placement is still unverified (bug #9) — fix
  the 5.27 key and confirm in the VM.
- **Weather polling** is the single sanctioned poller; keep its refresh interval
  conservative (e.g. 30–60 min) for the idle-CPU budget.
- **Hand-written appletsrc vs Plasma regeneration** — Plasma may reconcile our
  layout on first run (the wallpaper-drop class of bug). If the panel doesn't
  apply, seed it via the look-and-feel `layout.js` instead of skel appletsrc.

---

## 6. Testing checklist (VM)

- [ ] Footer shows, left→right: weather, Dyuti start, search box, gap, app icons, tray, clock, show-desktop.
- [ ] Search box renders as an inline pill; typing opens KRunner with results.
- [ ] No "Widget Removed" toast (all plugin ids resolve).
- [ ] App icons sit center-right (spacer working); pinned apps present.
- [ ] Tray curated (network/volume/battery/clipboard), clock shows date.
- [ ] Panel floats with `elev-2` shadow; consistent padding.
- [ ] Idle CPU ≈ 0 except weather's periodic refresh.

---

## 7. Implementation order

1. Add `kdeplasma-addons` to `desktop.list` (weather dependency).
2. Ship `org.dyuti.search` plasmoid in the branding package.
3. Rewrite the panel containment (appletsrc + look-and-feel `layout.js`) to the §3 order.
4. Build (`desktop branding cleanup iso`) → verify in VM against §6.
5. Skin via the Dyuti desktoptheme (PLAN-UNIFY-THEME Step 2) once that lands.

---

## References (Windows 11 taskbar)

- Taskbar height/icon sizes (48px default; small 32 / large 72) — Tom's Hardware, UMA Technology, GeeksforGeeks.
- Taskbar as command center; left widgets / centered cluster / right tray; edge positioning — Windows Insider Blog, Microsoft Learn.
