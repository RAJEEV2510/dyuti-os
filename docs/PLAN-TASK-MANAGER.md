# Dyuti OS — Task Manager (Windows-style)

> A Windows-11-style Task Manager for Dyuti: process list, live performance
> graphs, startup apps, end-task — opened with **Ctrl+Shift+Esc**. Built by
> customizing the already-shipped **`plasma-systemmonitor`** (native C++/Qt,
> themes via our Kvantum + color scheme), **not** a new app.
>
> Companion to [`DESIGN-SYSTEM.md`](DESIGN-SYSTEM.md) (Phase 11 Settings,
> Phase 15 perf) and [`PLAN-PANEL.md`](PLAN-PANEL.md). Base: Plasma 5.27 / Qt5.
>
> Last updated: 2026-06-27.

---

## 1. Goal

A user pressing **Ctrl+Shift+Esc** (or picking "Task Manager" from the menu /
panel) gets a clean, fast, Windows-familiar monitor: what's running, what it's
using, real-time graphs, and a one-click **End task** — all in the Dyuti theme.

**Why not build a new app:** `plasma-systemmonitor` already is, structurally,
the new Windows 11 Task Manager — a left nav rail + a process table +
performance pages with history graphs. It's native (cheap), already shipped
(`desktop.list`), and already themed by our Kvantum/scheme. We *configure and
brand* it; we don't reinvent it.

---

## 2. Windows 11 Task Manager — reference

| Win11 tab | Purpose |
|---|---|
| **Processes** (default) | Apps + background + Windows processes; CPU/Memory/Disk/Network per process; **End task**. |
| **Performance** | Live CPU, Memory, Disk, Network, GPU graphs + history. |
| **App history** | Resource usage history per app. |
| **Startup apps** | Auto-start programs + startup impact; enable/disable. |
| **Users** | Processes/usage grouped by logged-in user. |
| **Details** | Advanced per-process view. |
| **Services** | View/manage system services. |
| Shortcut | **Ctrl+Shift+Esc**; also right-click taskbar. |

Win11's new Task Manager uses a **left nav rail** (icons) + dark-mode follow —
which is exactly `plasma-systemmonitor`'s shape.

---

## 3. Mapping → Dyuti pages (plasma-systemmonitor)

Ship a curated default set of `plasma-systemmonitor` **pages** mirroring Win11:

| Win11 tab | Dyuti page | Native support | Notes |
|---|---|---|---|
| Processes | **Processes** (default page) | ✅ full | Table: name, user, CPU%, Memory, Disk, Network; End/Kill from row context menu. |
| Performance | **Performance** | ✅ full | History charts: CPU (total + per-core), Memory, Disk I/O, Network, GPU (if sensor present). |
| Details | folded into **Processes** | ✅ | systemmonitor's table already exposes advanced columns. |
| Users | **Users** | 🟡 partial | Group processes by user (column/filter); no separate session UI like Win11. |
| Services | **Services** | 🟡 partial | systemd services list (needs `systemd` sensor/KCM); document fallback to `systemctl`/systemd-kcm. |
| Startup apps | **Startup** → opens Autostart | 🟡 redirect | KDE manages autostart in System Settings → Autostart (`kcm_autostart`), not in the monitor. Ship a page/button that launches `kcmshell5 kcm_autostart`. |
| App history | — | ❌ N/A | KDE has no persistent per-app usage history. Omit; note as a known difference. |

Default landing page = **Processes** (matches Win11).

---

## 4. Files & KDE locations

**The app (already shipped).**
- `plasma-systemmonitor` (in `config/package-lists/desktop.list`).
- Depends on `ksystemstats` (sensor backend) — confirm it's pulled in; add explicitly if not.

**Custom default pages.**
- Ship Dyuti pages so a fresh user gets the Win11-like set without configuring.
- Page files (JSON) live per-user in `~/.local/share/plasma-systemmonitor/`; ship our defaults via skel:
  - `branding/.../etc/skel/.local/share/plasma-systemmonitor/org.dyuti.processes.page`
  - `.../org.dyuti.performance.page`
  - `.../org.dyuti.services.page`
- ⚠️ The `.page` JSON schema must be **captured from a live plasma-systemmonitor** (create the pages in the app once, copy the generated files) — hand-authoring blind risks an unloadable page. Do this during VM verification.

**Branding as "Task Manager".**
- `branding/.../usr/share/applications/org.dyuti.taskmanager.desktop`
  - `Name=Task Manager`, `GenericName=System Monitor`, `Exec=plasma-systemmonitor`,
    `Icon=utilities-system-monitor`, `Categories=System;Monitor;`,
    `Keywords=task;process;performance;cpu;memory;end task;`.
- Pin to Kickoff favorites + (optionally) the panel.

**Global shortcut (Ctrl+Shift+Esc).**
- `branding/.../etc/skel/.config/kglobalshortcutsrc` — register a launch action:
  - `[plasma-systemmonitor.desktop]` `_launch=Ctrl+Shift+Esc,none,Task Manager`
  - (Exact stanza/format to confirm in VM; alternative is a `khotkeys` command shortcut running `plasma-systemmonitor`.)

**Theming.** Automatic — inherits Kvantum widget style + Dyuti color scheme +
Tela icons. No extra theme work; just verify charts use accent/semantic tokens.

---

## 5. Performance considerations

- `plasma-systemmonitor` + `ksystemstats` only sample while **open** — near-zero
  cost when closed (does not violate the idle-CPU budget).
- Keep the default sample interval reasonable (1–2s) — don't over-poll.
- No GPU page if no GPU sensor (avoid an empty/erroring chart on plain VMs).
- Charts are native Qt — no QML/JS-heavy widgets.

---

## 6. Risks & gotchas

- **`.page` JSON schema** is version-specific — author on the live 5.27 app and
  copy out; don't hand-write blind (unloadable page = blank tab).
- **Ctrl+Shift+Esc** may be unbound or grabbed elsewhere — verify the
  `kglobalshortcutsrc` stanza actually fires in the VM.
- **Startup apps** isn't native to the monitor — we redirect to the Autostart
  KCM; set expectations (it's a separate window, unlike Win11's inline tab).
- **App history** has no KDE equivalent — document the omission so it's a
  deliberate difference, not a "missing feature."
- **Services** needs the systemd sensor present; fall back to systemd-kcm link.

---

## 7. Testing checklist (VM)

- [ ] Ctrl+Shift+Esc opens the monitor from anywhere.
- [ ] Lands on **Processes**; columns show CPU/Mem/Disk/Net; right-click → End task works.
- [ ] **Performance** page shows live CPU/Memory/Disk/Network graphs (GPU if present).
- [ ] Left nav rail reads clean in the Dyuti theme (light + dark).
- [ ] "Task Manager" appears in the start menu and launches the same app.
- [ ] Startup page/button opens Autostart settings.
- [ ] Closed app = ~0% CPU (sensors stop).

---

## 8. Implementation order

1. Confirm `plasma-systemmonitor` + `ksystemstats` are installed (add `ksystemstats` to `desktop.list` if missing).
2. Ship `org.dyuti.taskmanager.desktop` ("Task Manager") + pin to favorites.
3. Bind **Ctrl+Shift+Esc** in skel `kglobalshortcutsrc`.
4. In the VM: build the Processes/Performance/Services pages in the live app, copy the generated `.page` files into skel defaults.
5. Verify against §7; confirm theming in light + dark.

---

## References (Windows 11 Task Manager)

- Tabs (Processes/Performance/App history/Startup/Users/Details/Services) + Ctrl+Shift+Esc — HelpDeskGeek, Dellenny, Neowin, Windows Forum.
