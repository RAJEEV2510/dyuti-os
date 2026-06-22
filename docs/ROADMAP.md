# Roadmap

Working name **Dyuti** (Sanskrit: *radiance / light*). Original, smooth-UX
desktop for India — consumers **and** government. Ubuntu 24.04 LTS base, KDE
Plasma engine. Monetised via Free + Pro editions, support/SLA, OEM preloads,
govt tenders, custom services.

---

## One-Month Sprint → "Technical Alpha" (current focus)

Goal: a bootable, installable demo ISO. Rough, not sellable — for validation and
momentum. Scope is deliberately cut (see "Deferred").

| Week | Deliverable | Repo touchpoints |
|---|---|---|
| **W1** | Linux build env up; first bootable ISO (Ubuntu + Plasma) | `build/`, `chroot/`, `config/` (this scaffold) |
| **W2** | Branding package: theme, wallpaper, distinct look; own APT repo + GPG keys | `branding/`, new `repo/` infra |
| **W3** | Lean languages (Hindi + 1–2), IBus input; first-boot wizard; Calamares branding | `chroot/install-languages.sh`, `branding/etc/calamares/` |
| **W4** | QA on VMs, smoothness pass, update-through-repo test, cut Alpha, hand to testers | `docs/`, `dist/` |

### Deferred out of the 1-month sprint (do after)
- Full 12–22 language support (alpha ships ~3)
- Designer-built **design system** (alpha uses placeholder look)
- Broad **hardware QA** (alpha = VMs + own machine)
- Pro/edition tooling, App Center, Gov hardening, STQC/GeM, OEM deals
- Deep stability hardening (a demo may crash; a product must not)

---

## Full Quarter 1 (if you take the 3-month path instead)

- **Month 1** — Foundation: pipeline, first ISO, branding skeleton, APT repo + keys.
- **Month 2** — Identity: design system, layout switcher, full language stack,
  curated apps, first-boot wizard.
- **Month 3** — Hardening: installer polish, QA matrix, update channel proven,
  docs, **Alpha → trusted testers.**

## Beyond Q1 (high level)
- **Q2** — Public Beta, community, start OEM + tender conversations.
- **Q3** — Harden + commercial layer (Pro licensing, support portal, SLAs); RC.
- **Q4** — v1.0 GA, first paying deals, recurring revenue.

---

## Decisions locked
- Base: Ubuntu 24.04 LTS · Engine: KDE Plasma · Display: Wayland-capable (X11 fallback)
- Markets: consumers + government (dual)
- Money: Free + Pro + support + OEM + tenders + services
- Name: **parked** ("Dyuti" working title); revisit before public beta

## Open items
- [ ] Final name + `.in` domain + IP India trademark (class 9)
- [ ] Company registration (needed for GeM/tenders/OEM)
- [ ] Hire/contract: UI-UX designer, BD/OEM contact
- [ ] India server for APT repo + mirror
