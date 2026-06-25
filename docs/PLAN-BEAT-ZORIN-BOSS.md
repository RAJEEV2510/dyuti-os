# Plan: Reach Zorin OS, Beat BOSS Linux

> Status: planning doc. Created on branch `feature/zorin-parity-design`.
> Two distinct missions, two different strategies:
> - **Beat BOSS** = win India/government → languages + certification + sovereignty (we are already ahead on UX).
> - **Reach Zorin** = win the polish game → design system + hardware maturity + app experience.
>
> Phases are ordered by **leverage per hour**, not by difficulty.

---

## Where we stand (v0.1-alpha)

| Dimension | Dyuti (now) | Zorin OS | BOSS Linux | Gap |
|---|---|---|---|---|
| Base | Ubuntu 24.04 | Ubuntu 22.04 LTS | Debian | Par |
| Desktop | KDE Plasma + 3 layouts | GNOME, heavily customized | GNOME | Concept par, polish behind |
| Design system | Placeholders, 3 SVGs, 1 color scheme | Designer-built, multiple themes | Functional, dated | Behind Zorin; ahead of BOSS |
| Layout switcher | 3 presets | Zorin Appearance (6+, touch) | None | ~50% of Zorin |
| Indian languages | **4 locales** | N/A | **18+** | Biggest gap vs BOSS |
| Windows app support | Wine + winetricks | Wine + PlayOnLinux GUI | Limited | Slightly behind Zorin |
| App store | Discover (stock) | Polished store | Stock | Behind Zorin |
| Update infra | Scaffolded, not wired | Mature | C-DAC hosted, live | Not yet operational |
| Installer | Calamares (branded) | Custom, refined | Calamares/Ubiquity | Slightly behind Zorin |
| Hardware/QA | Live-boot just fixed | Years of field testing | Gov-certified | Far behind both |
| Certification/trust | None | Commercial brand | STQC certified | Critical gap for tenders |

**Bottom line:** Foundation is solid. The gap is **polish (Zorin), language breadth (BOSS), and institutional trust (BOSS)** — not architecture.

---

## Phase 0 — Lock the foundation (Weeks 1–2)

Make the current alpha rock-solid before adding anything.

- [ ] **QA matrix**: boot + install on real hardware + VirtualBox + QEMU + UEFI + BIOS + Secure Boot. Document in `docs/KNOWN-ISSUES.md`.
- [ ] **CI smoke-test gate**: cloud build workflow fails if the ISO doesn't boot headless in QEMU (boot → SDDM → autologin).
- [ ] **Reproducibility**: pin the Ubuntu mirror snapshot in `build/config.sh` for deterministic builds.

**Outcome:** stop shipping regressions. Non-negotiable before scaling features.

---

## Phase 1 — Beat BOSS on languages (Weeks 2–6)  ← highest leverage

Target **22 official Indian languages** (Eighth Schedule) to leapfrog, not match.

- [ ] `build/config.sh` → expand `SHIP_LOCALES` to all 22:
      `hi, bn, ta, te, mr, gu, kn, ml, pa, or, as, ur, sa, ks, sd, ne, kok, mai, doi, brx, mni, sat`
- [ ] `config/package-lists/languages.list` → add Noto/Lohit fonts for every script
      (Telugu, Kannada, Malayalam, Gujarati, Gurmukhi, Oriya, Meetei Mayek, Ol Chiki, etc.).
- [ ] `chroot/install-languages.sh` → IBus + m17n keymaps per language; default per-locale input method.
- [ ] First-boot **language picker** in `dyuti-welcome` (Qt/QML runtime already shipped).

**Outcome:** ship more and better-integrated languages than BOSS, with a modern picker. Strongest competitive claim, ~4 weeks.

---

## Phase 2 — Reach Zorin on design (Weeks 4–12, parallel)  ← needs a designer, start week 1

Cannot be closed with shell scripts. Longest pole; run it in parallel.

- [ ] Replace placeholders: `in.dyuti.lookandfeel` global theme + custom SDDM theme (currently falls back to Breeze).
- [ ] Kvantum theme: rounded corners, blur, consistent saffron accent across Qt + GTK.
- [ ] Plymouth boot splash: branded animation, not stock.
- [ ] Calamares slideshow: real visuals (un-defer from roadmap — first impression).
- [ ] Cohesion pass: dark + light variants, matching cursor/icon/window-decoration set.

**Outcome:** a real custom global theme closes ~70% of the perceived gap. Full parity is 6–12 months.

---

## Phase 3 — Feature parity with Zorin Appearance (Weeks 8–12)

We are at ~50% with 3 layout presets. Finish it.

- [ ] Expand `dyuti-layouts` from 3 → 6 presets (add GNOME-style, Ubuntu-style, Touch/tablet).
- [ ] Wrap it in a **GUI** (currently CLI `/usr/bin/dyuti-layouts`) using the Qt/QML runtime.
- [ ] Add light/dark toggle + accent picker to the same GUI.

**Outcome:** "Dyuti Appearance" becomes a headline feature matching Zorin's signature tool.

---

## Phase 4 — Sovereignty backbone goes live (Weeks 6–14, parallel)

Beats BOSS on transparency; required for updates, security, monetization.

- [ ] Wire scaffolded `repo/` into the build: bundle `dyuti-archive-keyring.deb` into the ISO.
- [ ] Stand up the India server (aptly + GPG — scaffold is ready).
- [ ] Ship a **security update channel** (India-hosted, signed, transparent, in-git).

**Outcome:** operational update sovereignty — a procurement differentiator.

---

## Phase 5 — The trust game vs BOSS (Months 4–18)  ← not an engineering problem

Decides government tenders. Longest lead time — start the clock now.

- [ ] **STQC / CERT-In certification** path (often a procurement requirement).
- [ ] **Institutional backing / partnership** (BOSS has C-DAC; need an equivalent anchor).
- [ ] **Pilot deployment** with one state department or university.
- [ ] **Compliance docs**: accessibility, data-locality, audit trail.

**Outcome:** the multi-year moat. Begin paperwork now.

---

## Sequencing summary

| Track | Weeks | Closes gap vs | Effort |
|---|---|---|---|
| Phase 0 — QA/CI hardening | 1–2 | Both (regressions) | Low, critical |
| Phase 1 — 22 languages | 2–6 | **Beats BOSS** | Low, high ROI |
| Phase 2 — Design system | 4–12 | **Reaches Zorin** | High, needs designer |
| Phase 3 — Appearance GUI | 8–12 | Zorin parity | Medium |
| Phase 4 — Update repo live | 6–14 | Beats BOSS (trust) | Medium |
| Phase 5 — Certification | 4–18 mo | **Wins gov tenders** | Institutional, slow |

**Start in week 1 (longest lead times):** hire the designer (Phase 2), begin certification paperwork (Phase 5), lock CI/QA (Phase 0).
**Fastest visible win + strongest claim:** Phase 1 (languages).
