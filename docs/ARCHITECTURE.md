# Architecture

## Big picture

Dyuti OS is **not built from scratch**. It stands on a stable, long-term-support
Linux base (kernel, drivers, thousands of maintained packages) and reshapes the
desktop layer into an original product. Everything the *user* sees — look,
defaults, apps, languages, installer, update source — is ours.

```
                 ┌───────────────────────────────────────────────┐
                 │                 Dyuti OS                        │
                 │  branding · design system · apps · languages    │
                 │  first-boot wizard · App Center · update client │
                 ├───────────────────────────────────────────────┤
                 │         Modern Qt desktop (reshaped)            │  ← desktop engine
                 ├───────────────────────────────────────────────┤
                 │          Stable LTS Linux package base          │  ← foundation
                 │        Linux kernel · drivers · systemd         │
                 └───────────────────────────────────────────────┘
```

## Build pipeline (this repo)

The ISO is produced by a 6-stage pipeline (`build/stages/`), each a small,
re-runnable script. State lives in `build/work/` (git-ignored).

| Stage | Script | What it does |
|---|---|---|
| 10 | `10-bootstrap.sh` | `debootstrap` a minimal base system into `work/chroot` |
| 20 | `20-configure.sh` | apt sources, hostname, locales; bind-mount /proc /sys /dev |
| 30 | `30-desktop.sh` | inside chroot: kernel + live boot, desktop, apps, languages, installer |
| 40 | `40-branding.sh` | build `dyuti-branding.deb` (templated os-release) and install it |
| 50 | `50-cleanup.sh` | clear caches/logs, blank machine-id, shrink the chroot |
| 60 | `60-iso.sh` | squashfs the chroot, add GRUB, build a hybrid BIOS+UEFI ISO |

Output: `dist/dyuti-<version>-amd64.iso`.

### Why this approach (vs Cubic / live-build)
- **Scripted + reproducible** — the whole OS is defined in git; rebuild anytime.
- **Full control** — we own every customization point (vs a GUI remaster).
- **Native live boot** — uses the standard `casper` live-boot system, so the
  live + install experience matches what users expect from mainstream Linux.

## Update / sovereignty backbone (next phase)

For the alpha the system updates from the upstream base archive. The product plan adds:
- An **India-hosted APT repo** (`aptly`/`reprepro`) with **our GPG signing keys**.
- A **mirror** of upstream into Indian infra (the "indigenous supply chain" claim).
- An **update/entitlement client** that gates Pro features and support tiers.

## Editions (productization)

One build pipeline, multiple seed sets → Free, Pro, Lite (XFCE), Gov (hardened).
Edition differences are expressed as package-list + branding overlays, not forks.

## Legal / licensing

- Built from GPL/open-source packages — honour their licenses; provide source.
- **Do not imply upstream endorsement.** Dyuti is an independent product built on
  open-source components; the upstream projects do not endorse it.
- The brand assets in `branding/` are *ours* — trademark them (software class 9).
- Keep telemetry opt-in (India DPDP Act) — privacy is a selling point.
