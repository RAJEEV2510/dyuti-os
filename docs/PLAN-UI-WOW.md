# Plan: The "WOW" UI Pass — Design System as Code

> Goal: make Dyuti's desktop look so good it sells itself — Zorin-level polish or better.
> This is the depth-version of Phase 2 + Phase 3 in `PLAN-BEAT-ZORIN-BOSS.md`.

---

## How this actually works (the method)

We don't hand-paint in Figma. A KDE Plasma look is **assets + config**, all of which
agents can author for real and commit into the `dyuti-branding` .deb:

- SVG wallpapers, Plasma **color schemes**, **Kvantum** Qt themes
- **SDDM** login screen (QML), **Plymouth** boot splash (script/images)
- **GTK** CSS (so GTK apps match KDE), cursor + icon accent recolor
- Plasma **Look-and-Feel** package (the global theme), panel layouts, Welcome app (QML)

The thing that makes it "wow" instead of "fine" is a **closed visual feedback loop**:

```
author asset  ->  build ISO (incremental)  ->  boot in QEMU + screenshot
      ^                                                      |
      |__________  critique the screenshot, refine  <________|
```

Your repo already does QEMU screenshots (that filled `dist-test/`). We reuse that as a
**design QA harness**: every iteration produces a real screenshot we judge against a
north-star, not guesswork.

---

## North star (visual identity)

**Direction (locked): Premium dark, restrained accent.** Flagship and understated.

- **Concept:** *Dyuti = radiance.* A serious, high-craft OS where the saffron glow is rare and
  intentional — light in the dark, not color everywhere.
- **Accent:** saffron `#ff9d4d` used **sparingly** — focus rings, active states, the one thing
  that draws the eye. Never as fill or decoration.
- **Base:** near-black / charcoal darks; crisp neutral grey-white light variant. Both must ship.
- **Type:** Inter (UI), Fira Code (mono) — already selected.
- **Feel:** high contrast, minimal, sharp. Soft-but-tight radius, restrained blur, depth via
  shadow not border. Generous spacing. Apple-flagship discipline.
- **Rule:** one accent, consistent radius, consistent spacing across *every* surface.
  Cohesion + restraint is what reads as "premium."

---

## Deliverables (each is a real artifact in the branding deb)

| # | Asset | What "wow" means | File target |
|---|-------|------------------|-------------|
| 1 | **Wallpaper set** | 3–5 layered SVG: default (dawn), light, lock, plus 2 alts | `/usr/share/backgrounds/dyuti/` |
| 2 | **Color scheme** | Upgrade `Dyuti.colors` — full dark + new light, tuned contrast | `/usr/share/color-schemes/` |
| 3 | **Kvantum theme** | Rounded corners, blur, soft shadows, saffron focus rings | `/usr/share/Kvantum/Dyuti/` |
| 4 | **Global Look-and-Feel** | Replace the placeholder `in.dyuti.lookandfeel` — real splash, defaults, layout | `/usr/share/plasma/look-and-feel/` |
| 5 | **SDDM login** | Custom QML theme (stop falling back to Breeze) — blurred wallpaper, centered card | `/usr/share/sddm/themes/dyuti/` |
| 6 | **Plymouth splash** | Branded boot animation, saffron progress, logo reveal | `/usr/share/plymouth/themes/dyuti/` |
| 7 | **GTK theme** | GTK3/4 CSS so Chrome/GIMP/Inkscape match the KDE look | `/etc/skel/.config/gtk-*/` + theme |
| 8 | **Icons + cursor** | Papirus recolored to saffron accent folders; matched cursor | `look.list` + recolor step |
| 9 | **Panel/layout polish** | Refined default "Dyuti Modern" — floating panel, spacing, blur | appletsrc in branding deb |
| 10 | **Welcome app UI** | First-boot QML: language picker + tour, genuinely beautiful | `dyuti-welcome` |
| 11 | **Calamares slideshow** | Real install-time visuals (un-defer from roadmap) | `/etc/calamares/branding/dyuti/` |

---

## The agent pipeline

A multi-stage flow we can run as a workflow:

1. **Direction agent** — lock the design tokens (palette ramp, radius scale, spacing scale,
   shadow/blur values, type scale) into one `design-tokens.md`. Everything downstream reads it.
2. **Per-asset author agents (parallel)** — one agent per deliverable above, each consuming the
   tokens so the output is coherent, not 11 different styles.
3. **Build + screenshot** — incremental ISO rebuild (`wsl-sync-build.sh`), boot in QEMU, capture:
   login screen, desktop, app windows, dark + light.
4. **Visual critique agent** — judge each screenshot against the north star; produce a punch-list
   of specific fixes (contrast, alignment, radius mismatch, weak hierarchy).
5. **Refine loop** — feed punch-list back to the author agents. Repeat until it reads as "wow."
6. **Cohesion critic** — final pass: does login → boot → desktop → installer feel like *one*
   product? Fix the seams.

---

## Milestones

| Milestone | Deliverables | Outcome |
|-----------|--------------|---------|
| **M1 — Tokens + palette** | #2 color scheme, `design-tokens.md` | Foundation every asset shares |
| **M2 — First impressions** | #1 wallpaper, #5 SDDM, #6 Plymouth | The first 30 seconds look premium |
| **M3 — The desktop** | #3 Kvantum, #4 global theme, #8 icons, #9 panel | Daily-driver surface is cohesive |
| **M4 — App consistency** | #7 GTK theme | GTK apps stop looking foreign |
| **M5 — Journey polish** | #10 Welcome, #11 Calamares | First-boot + install feel designed |
| **M6 — Cohesion pass** | critique + refine across all | Ships as one product, not parts |

---

## How we judge "wow" (acceptance bar)

- A stranger's first reaction to a screenshot is "what OS is *that*?" — not "looks like Linux."
- Login, boot, desktop, and installer share one accent, one radius, one spacing rhythm.
- Light and dark both look intentional (not one good, one afterthought).
- Nothing falls back to Breeze defaults anywhere in the first-run journey.
- Side-by-side with a Zorin screenshot, Dyuti holds its own or wins.

---

## Start order

1. Confirm the **north-star direction** (evolve saffron+indigo+dawn, or new).
2. Run the **Direction agent** → `design-tokens.md`.
3. Kick **M2 (first impressions)** first — biggest perceived-quality jump per hour.
