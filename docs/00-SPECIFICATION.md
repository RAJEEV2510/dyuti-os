# Dyuti OS — Master Specification (PRD Index)

> **Status:** living document · **Owner:** core team · **Last structured:** 2026-06
>
> This is the **root of the Dyuti OS Product Requirements Document**. It defines
> the vision, the document map, the standard spec template, and the full feature
> inventory. Every subsystem gets its own file under `docs/`; this page is the
> index and the rules that keep all of them consistent.
>
> **How to use this with AI / contributors:** pick one subsystem file, implement
> it to its acceptance criteria, check it off in the index below, then move to the
> next. The PRD — not ad-hoc chat — is the source of truth for *what* Dyuti is.

---

## 1. Vision (the one-paragraph north star)

Dyuti OS is an **India-first consumer + government desktop OS** built on a stable
LTS Linux foundation (KDE Plasma, reshaped beyond recognition). It must feel as
polished as Windows 11 / macOS, be friendlier to migrate to than **Zorin OS**,
ship Indian languages and government services (DigiLocker, UPI, UMANG, ABHA) out
of the box, run on an India-hosted update/security backbone, and be deployable at
scale for government/enterprise (kiosk, policy, fleet management). Beating Zorin
is the *near-term* bar; the *long-term* bar is being the default OS for India.

Full vision narrative: see [`00-VISION.md`](00-VISION.md) *(to be written)* and the
existing [`README.md`](../README.md).

---

## 2. Where this fits with existing docs

This repo already has real planning docs. The PRD **absorbs and supersedes** the
ad-hoc plans over time; until then, treat them as source material:

| Existing doc | Role going forward |
|---|---|
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Folds into `01-ARCHITECTURE.md` |
| [`ROADMAP.md`](ROADMAP.md) | Folds into `02-ROADMAP.md` |
| [`design-tokens.md`](design-tokens.md) | Becomes `04-DESIGN-TOKENS.md` (canonical) |
| `PLAN-BEAT-ZORIN-BOSS.md`, `PLAN-UI-WOW.md`, `PLAN-WOW-PROGRESS.md` | Mined into subsystem specs, then archived |
| [`KNOWN-ISSUES.md`](KNOWN-ISSUES.md) | Stays; per-subsystem issues link here |
| [`../PLAN.md`](../PLAN.md) | The active near-term task list (footer, menus, webcam, desktops, search) — feeds the relevant subsystem specs |

---

## 3. Technical foundation (grounded in this repo — not aspirational)

So every subsystem spec stays realistic about *how* it ships:

- **Base:** Ubuntu/Debian LTS via a scripted `live-build`-style pipeline
  (`build/build.sh` stages 10–60: bootstrap → configure → desktop → branding →
  cleanup → iso). Output: `dist/dyuti-<version>-amd64.iso`.
- **Desktop:** **KDE Plasma**, restyled. Widget style **Breeze** driven by the
  `DyutiLight` / `Dyuti` color schemes. Kvantum themes shipped but inactive.
- **Customization delivery:** almost everything ships inside the
  **`dyuti-branding` .deb** (`branding/dyuti-branding/`) — skel configs
  (`kdeglobals`, `kwinrc`, `plasma-*-appletsrc`), color schemes, look-and-feel,
  SDDM theme, Plymouth, Calamares branding, helper binaries (`dyuti-*`).
- **Installer:** Calamares (branded "Install Dyuti OS"). **Login:** SDDM.
  **Boot splash:** Plymouth `dyuti` theme.
- **Build levers:** `make refresh` (incremental: reuse chroot, re-brand, repack)
  vs `make desktop` + `make iso` (when a **new package** is added).

This means most subsystem specs decompose into: *(a)* packages to add, *(b)* skel
configs / theme files in the branding deb, *(c)* optional custom helper apps
(`dyuti-*` QML/binaries), *(d)* build-stage wiring.

---

## 4. Document map (the PRD tree + status)

Legend: ☐ not started · ◐ drafted · ☑ complete (spec written to template).
*(Build the tree incrementally — this index is the master checklist.)*

### Core
- ☐ `00-VISION.md` — mission, positioning vs Zorin/Win11/ChromeOS/macOS, success metrics
- ◐ `01-ARCHITECTURE.md` — system layers, build pipeline, branding-deb model *(exists as ARCHITECTURE.md)*
- ◐ `02-ROADMAP.md` — phased delivery, release gates *(exists as ROADMAP.md)*
- ☐ `03-DESIGN-SYSTEM.md` — components, layout, interaction patterns
- ◐ `04-DESIGN-TOKENS.md` — color/type/spacing/motion tokens *(exists as design-tokens.md)*

### desktop/
- ☐ Desktop-Shell · ☐ Panel · ☐ Launcher · ☐ Taskbar · ☐ Notification-Center
- ☐ Quick-Settings · ☐ Desktop-Widgets · ☐ Window-Manager · ☐ Virtual-Desktop
- ☐ Dock · ☐ Context-Menus · ☐ Clipboard · ☐ Search · ☐ File-Preview · ☐ Lock-Screen

### system/
- ☐ Boot · ☐ Login · ☐ Installer · ☐ Welcome · ☐ Update-System · ☐ Driver-Manager
- ☐ Recovery · ☐ Backup · ☐ Restore · ☐ Firewall · ☐ Security · ☐ Package-System
- ☐ Logs · ☐ Telemetry

### settings/
- ☐ Appearance · ☐ Display · ☐ Sound · ☐ Network · ☐ Bluetooth · ☐ Keyboard
- ☐ Mouse · ☐ Touchpad · ☐ Accessibility · ☐ Storage · ☐ Power · ☐ Privacy
- ☐ Accounts · ☐ Language · ☐ Time · ☐ Updates · ☐ About

### apps/
- ☐ Store · ☐ Files · ☐ Terminal · ☐ Camera · ☐ Calculator · ☐ Notes
- ☐ Screenshot · ☐ Screen-Recorder · ☐ Archive · ☐ Image-Viewer · ☐ PDF
- ☐ Media · ☐ Text-Editor

### cloud/
- ☐ Dyuti-ID · ☐ Sync · ☐ Backup · ☐ Device-Link · ☐ Phone-Link · ☐ Nearby-Share · ☐ Notifications

### india/
- ☐ Languages · ☐ Indic-Input · ☐ DigiLocker · ☐ UPI · ☐ Aadhaar · ☐ UMANG
- ☐ GST · ☐ Passport · ☐ ABHA · ☐ Government

### ai/
- ☐ Assistant · ☐ Offline-AI · ☐ OCR · ☐ Translation · ☐ Voice · ☐ Automation

### developer/
- ☐ SDK · ☐ CLI · ☐ Theme-API · ☐ Extension-API · ☐ Widget-API · ☐ Packaging

### branding/
- ☐ Icons · ☐ Wallpapers · ☐ Colors · ☐ Typography · ☐ Animations · ☐ Motion

### release/
- ☐ Alpha · ☐ Beta · ☐ RC · ☐ Stable · ☐ LTS

### enterprise/ *(added — your "Enterprise & Government" area needs its own home)*
- ☐ Device-Management · ☐ Kiosk-Mode · ☐ Directory-LDAP · ☐ Policy-Management
- ☐ Offline-Repo · ☐ Secure-Deploy · ☐ Audit-Logging · ☐ Remote-Admin

### gaming/ *(added — your "Gaming" area)*
- ☐ Steam · ☐ Proton-Manager · ☐ FPS-Overlay · ☐ Performance-Profiles
- ☐ GPU-Switcher · ☐ Game-Launcher

---

## 5. Standard subsystem spec template

**Every** file under the folders above uses this exact skeleton, so the PRD reads
consistently and AI tools can fill one in without guessing structure. Copy this
block into each new doc.

```markdown
# <Subsystem Name>

> Area: <desktop|system|settings|apps|cloud|india|ai|developer|branding|enterprise|gaming>
> Status: ☐ spec / ☐ designed / ☐ in-build / ☐ shipped
> Owner: <name> · Target release: <Alpha|Beta|RC|Stable|LTS> · Priority: P0|P1|P2|P3

## 1. Purpose & goals
What this is, why it exists, and how it advances the vision (India-first /
beat-Zorin / government-ready). 2–4 sentences + a bulleted goal list.

## 2. Non-goals
What this explicitly does NOT do (prevents scope creep).

## 3. User stories
- As a <persona>, I want <capability>, so that <benefit>.
(Personas: everyday consumer, first-time Linux switcher, govt clerk, IT admin,
Indic-language user, developer.)

## 4. UX / UI description
Layout, states, key flows. ASCII mockup or annotated description. Reference
04-DESIGN-TOKENS.md for color/spacing/motion — never hardcode values here.

## 5. Technical architecture
How it ships in Dyuti's model:
- Packages to add (which package-list).
- Branding-deb files (skel config / theme / look-and-feel) to add or change.
- Custom helper app/plasmoid (dyuti-*) if any — language, modules.
- Build-stage wiring (refresh vs desktop+iso).
- Upstream component reused vs built new (prefer reuse; KDE first).

## 6. APIs / components / config keys
Concrete config keys (e.g. kwinrc [Desktops]Number), D-Bus services, file paths,
or public APIs other subsystems depend on.

## 7. Dependencies
Other subsystems / packages / services this needs, and who needs it.

## 8. Implementation phases
Phase 1 (MVP) → Phase 2 → Phase 3, each shippable. Map to release gates.

## 9. Acceptance criteria
Checklist a reviewer verifies on a booted ISO. Must be objective.

## 10. Risks & future enhancements
Known risks, India-specific compliance notes, and post-MVP ideas.
```

---

## 6. Feature inventory (the backlog, by area)

The complete competitive feature set. Each line becomes a section in (or a whole)
subsystem spec. Priority: **P0** = needed to beat Zorin / ship Stable · **P1** =
strong differentiator · **P2** = nice-to-have · **P3** = long-term.

### Desktop experience
Modern desktop shell `P0` · custom launcher with universal search `P0` · dynamic
dock & taskbar `P0` · widgets `P1` · clipboard history `P1` · snap layouts `P1` ·
virtual desktops `P0` · session restore `P1` · focus mode `P2` · night light `P1` ·
dynamic wallpapers `P2` · live wallpapers `P3` · notification center `P0` ·
unified quick settings `P0` · gestures `P2` · touch/tablet mode `P2`.

### Settings
Custom Settings app `P1` · search-in-settings `P1` · import/export config `P2` ·
reset individual settings `P2` · multiple user profiles `P1` · theme editor `P2` ·
accent-color generator `P2` · font manager `P2`.

### System
One-click updates `P0` · driver manager `P0` · recovery mode `P0` · rollback `P1` ·
snapshot manager `P1` (Timeshift already in apps.list) · boot repair `P1` ·
diagnostics `P1` · health monitor `P2` · disk cleanup `P1` · startup manager `P2`.

### Security
Secure Boot `P0` · TPM `P1` · disk-encryption wizard `P0` · firewall UI `P1` ·
permission manager `P1` · privacy dashboard `P1` · app sandboxing `P2` ·
password vault `P2`.

### Productivity apps
Clipboard manager `P1` · OCR `P1` · PDF tools `P1` (Okular shipped) · screenshot
`P0` (Spectacle shipped) · screen recorder `P1` · notes `P1` · calculator `P0`
(KCalc shipped) · calendar `P1` · tasks `P2` · whiteboard `P3`.

### Store / package
Native apps `P0` · Flatpak `P0` · Snap optional `P2` · AppImage `P1` · web apps /
PWA `P2` · firmware updates `P1` (fwupd shipped) · ratings & reviews `P2`.

### AI
Offline assistant `P1` · voice control `P2` · local LLM `P2` · smart search `P1` ·
translation `P1` · OCR `P1` · code assist `P3` · summarization `P2`.

### Phone integration
Android notifications `P1` · SMS `P2` · calls `P2` · clipboard sync `P1` · file
transfer `P1` (KDE Connect basis) · screen mirroring `P2` · camera-as-webcam `P2`
· hotspot control `P2`.

### Gaming
Steam `P1` · Proton manager `P2` · FPS overlay `P3` · performance profiles `P2` ·
GPU switcher `P2` · game launcher `P2`.

### India platform `P0 area`
Multi-language installer `P0` · Indic fonts `P0` · Indic keyboard layouts `P0` ·
UPI app recommendations `P1` · DigiLocker `P1` · UMANG shortcuts `P1` · government
service links `P1` · Bharat Maps `P2` · localized onboarding `P0`.

### Developer experience
SDK `P2` · Theme API `P2` · Extension API `P2` · Widget API `P2` · package builder
`P2` · CLI tools `P1` · docs generator `P3`.

### Enterprise & government `P0 area for govt deals`
Centralized device management `P1` · kiosk mode `P1` · AD/LDAP `P1` · policy mgmt
`P1` · offline package repo `P1` · secure deployment images `P1` · audit logging
`P1` · remote administration `P2`.

---

## 7. Conventions

- **One subsystem per file.** No mega-docs except this index.
- **Reuse before build.** KDE/upstream first; only build custom (`dyuti-*`) when
  upstream can't deliver the experience.
- **Tokens, not hardcodes.** All visual values come from `04-DESIGN-TOKENS.md`.
- **Acceptance criteria are testable on a booted ISO** — no "looks nice".
- **Every spec states its build path** (`make refresh` vs `make desktop`+`iso`).
- **Keep the index honest** — update the ☐/◐/☑ status when a spec lands.

---

## 8. Suggested authoring order (so the PRD compounds, not sprawls)

1. **Core** (00–04) — vision, architecture, design system/tokens. Everything
   references these, so write them first.
2. **desktop/** — the daily-use surface and where we beat Zorin visually.
3. **system/ + settings/** — the "it's a real OS" backbone.
4. **india/** — the core differentiator and government wedge.
5. **apps/ + store/** — completeness.
6. **cloud/ + ai/ + phone/ + gaming/** — differentiation layers.
7. **developer/ + enterprise/** — ecosystem & revenue.
8. **release/** — gates that decide when each of the above is "done enough".

> Next step after this file: write **`00-VISION.md`** and promote the existing
> `ARCHITECTURE.md` / `ROADMAP.md` / `design-tokens.md` into the numbered core
> set, then scaffold each folder's files from the template in §5.
