# Dyuti OS — Panel Fix Plan (features 6–9)

> Recovery plan after the panel-redesign batch broke the footer. Re-adds the
> rolled-back features the **right** way. Last updated: 2026-06-28.

## Root cause
All failures came from customizing the panel by **seeding `appletsrc`** (and a
custom desktoptheme). Plasma reconciles the panel on first boot and our edits
made it render collapsed/invisible:
- Custom search plasmoid collapsed the panel to 30px (its TextField height).
- `panelOpacity` in seeded appletsrc tripped first-run regeneration.
- Incomplete custom desktoptheme (no SVGs) rendered transparent.

**Reliable channel:** the Plasma **scripting API** — define the panel in the
look-and-feel `layout.js` and/or apply tweaks via `evaluateScript` at first login
(the same pattern `dyuti-theme` uses for the wallpaper). NEVER seed panel
customizations in `appletsrc` again.

## Principles
1. Seeded `appletsrc` stays stock/known-good — the boot panel must always render.
2. All customization via the scripting API (`layout.js` / first-login script).
3. ONE feature per build, each with a **geometry gate**: after adding, check
   `panels()` — if thickness < 40 or not full-width, roll back that step.
4. Every risky feature has a fallback.

## Steps
- **0. Baseline** — confirm the reverted stock panel boots & renders.
- **1. Desktop switcher (#8)** — add `org.kde.plasma.pager` via scripting. Gate.
- **2. Clean launcher (#9)** — Kickoff + dyuti-logo; explicit clean pins via
  scripting (no comma `launchers=` in appletsrc). Gate.
- **3. Inline search (#7)** — test fixed `org.dyuti.search` in isolation + geometry
  gate. Fallback: search-first Kickoff or `Ctrl+Space` -> KRunner.
- **4. Footer gray (#6)** — panel opacity/color via first-login `evaluateScript`
  only (never seeded). Fallback: keep stock light panel.

Order: 8 -> 9 -> 7 -> 6 (easiest/safest first).

## 2026-06-28 — the real root cause: appletsrc suppresses layout.js
First boot of the new build still showed the stock panel (weather/kickoff/
icontasks/tray/clock) — no search, no pager, no Task View — even after waiting
out the autostart's 90 s window. Two compounding causes:

1. **Structural (the real one):** Plasma runs the look-and-feel `layout.js` (the
   canonical default-layout channel) ONLY when there is no existing
   `plasma-org.kde.plasma.desktop-appletsrc`. Skel shipped one, so Plasma loaded
   that stock panel and **never ran `layout.js`** — our updated Win11 layout was
   dead code the whole time.
2. **The autostart workaround is fragile:** `dyuti-panel-setup` depends on skel
   autostart copy + OnlyShowIn + phase-2 + qdbus/D-Bus `evaluateScript` + a 90 s
   race. With no Guest Additions we can't even read its log. Too many failure
   points.

Fix batch:
- **Delete the seeded `appletsrc`** → plasmashell runs our `layout.js` at startup
  (same mechanism KDE uses for default panels). Single, reliable channel. Cannot
  regress to an empty panel (Plasma always guarantees a default); custom-widget
  `add()`s are guarded so a bad plasmoid can't abort the layout.
- `layout.js`: already holds the full Win11 order (launcher, search, taskview,
  pager, icontasks, spacer, tray, clock, showdesktop), guarded.
- `desktop.list`: keep `qdbus-qt5` explicit (real provider of `/usr/bin/qdbus`).
- `dyuti-panel-setup`: kept as harmless redundancy; now logs to
  `~/.config/dyuti/panel-setup.log`. It only mutates the panel if qdbus connects,
  so it can't half-empty the layout.js panel.

## 2026-06-28 (cont.) — custom plasmoids silently dropped: missing X-Plasma-API
After deleting the appletsrc, `layout.js` ran and the panel rebuilt — but only the
STOCK pager appeared; both custom plasmoids (`org.dyuti.search`, `org.dyuti.taskview`)
were silently skipped by the guarded `add()`. Diagnosed in the chroot (no VM needed):
- `kpackagetool5 --show org.dyuti.search` worked (metadata readable) but the applet
  never instantiated in plasmashell.
- Diff vs the stock pager's `metadata.json` showed ours lacked the fields that tell
  plasmashell to load it as a QML applet:
  `"X-Plasma-API": "declarativeappletscript"` and `"X-Plasma-MainScript": "ui/main.qml"`
  (plus `ServiceTypes: ["Plasma/Applet"]`). Without `X-Plasma-API` the loader reads the
  package but never invokes the QML engine → the widget silently doesn't appear.
- Added those fields to both plasmoids. Verified headlessly with
  `QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software dbus-run-session plasmawindowed
  org.dyuti.search` → loads clean ("requesting config … without a containment", no QML
  errors). Same for taskview.

Lesson: a custom QML plasmoid needs `X-Plasma-API: declarativeappletscript` +
`X-Plasma-MainScript` in metadata.json, or it's discoverable-but-unloadable. Validate
new plasmoids in the chroot with `plasmawindowed` (software backend) BEFORE an ISO build.

## 2026-06-28 (cont.) — user feedback: inline search, drop the pager
After the panel rendered correctly, user feedback:
- Search opening the KRunner overlay "above" is unwanted — results should appear
  from the box itself.
- The pager (two virtual desktops) isn't needed; the Task View "+" is how they'll
  add desktops. Keep the Task View icon.

Changes:
- `org.dyuti.search` rewritten: TextField (stays in the panel, keeps focus) +
  `Milou.ResultsView` in a `PlasmaCore.Dialog` flagged `WindowDoesNotAcceptFocus`,
  shown above the box while typing. Up/Down/Enter forwarded to the results view.
  Depends on the `org.kde.milou` QML module → pinned `milou` in `desktop.list`.
- Removed `org.kde.plasma.pager` from `layout.js` and `dyuti-panel-setup`.
- `kwinrc`: one virtual desktop by default (was two — that was only to make the
  pager useful).
- Validated the new search QML headlessly with `plasmawindowed` (offscreen +
  software backend): loads clean, milou import resolves.

## Safety net
- `git` holds the known-good appletsrc -> any step rolls back in seconds.
- Geometry gate catches a broken panel before the user sees it.
