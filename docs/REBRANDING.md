# Rebranding coverage

Goal: an end user never sees any upstream project name or logo — only **Dyuti**.
Removing upstream marks is required by their trademark policies when remixing
(licenses are still honoured; this is branding, not code stripping).

## Where each mark is replaced

| Surface | Default | Now | Where |
|---|---|---|---|
| `os-release` | upstream | Dyuti (+ LOGO, accent) | `build/stages/40-branding.sh` |
| `lsb-release` | upstream | Dyuti | `chroot/rebrand.sh` |
| Console banner (`/etc/issue`) | upstream | Dyuti OS | `chroot/rebrand.sh` + branding pkg |
| Dynamic MOTD (welcome text, news/ads) | on | disabled | `chroot/rebrand.sh` |
| Live session user | upstream default | `dyuti` | `/etc/casper.conf` via `rebrand.sh` |
| Bootloader name (installed) | upstream | Dyuti OS | `GRUB_DISTRIBUTOR` via `rebrand.sh` |
| GRUB menu (live ISO) | — | Dyuti | `build/stages/60-iso.sh` |
| Boot splash | upstream logo | Dyuti radiance | branding pkg `plymouth/themes/dyuti` |
| Startup splash (login→desktop) | upstream logo | Dyuti | look-and-feel `contents/splash/Splash.qml` |
| Login screen | default theme | Dyuti theme | branding pkg `sddm/themes/dyuti` |
| Menu button icon | default start-here | `dyuti-logo` | look-and-feel layout JS |
| Desktop look / colors | default | Dyuti global theme | look-and-feel + color scheme |
| Installer | default branding | Dyuti | branding pkg `calamares/branding/dyuti` |
| Wallpaper | default | Dyuti | branding pkg |
| Upstream fluff packages | installed | purged (best-effort) | `chroot/rebrand.sh` |

## The one honest caveat

**System Settings → About** shows factual desktop/framework version lines. These
are *version information*, not branding, and can't be hidden without patching the
About module's source. The OS identity, logo, and accent there are all Dyuti. If
a government/enterprise buyer requires it fully gone, that's a small source patch
we can do later — not needed for the alpha.

## What stays (functional, not user-visible)

The build scripts still reference the upstream package archive URL and a few
upstream package names (e.g. in the purge list and a live-boot marker filename).
These are **functional** — they are how the system fetches and boots software —
and are never shown to an end user. Point `BASE_MIRROR` at your own India-hosted
mirror to remove even the archive URL from the pipeline.

## Verify on a built system
```bash
cat /etc/os-release /etc/lsb-release   # → Dyuti
lsb_release -a                         # → Dyuti
cat /etc/issue                         # → Dyuti OS
grep DISTRIBUTOR /etc/default/grub     # → Dyuti OS
```
