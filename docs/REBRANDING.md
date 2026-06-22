# Rebranding coverage

Goal: an end user never sees "Ubuntu" or "KDE/Plasma/Breeze" — only **Dyuti**.
Removing upstream marks is required by Canonical/KDE trademark policy when
remixing (licenses are still honoured; this is branding, not code stripping).

## Where each mark is replaced

| Surface | Default | Now | Where |
|---|---|---|---|
| `os-release` | Ubuntu | Dyuti (+ LOGO, accent) | `build/stages/40-branding.sh` |
| `lsb-release` | Ubuntu | Dyuti | `chroot/rebrand.sh` |
| Console banner (`/etc/issue`) | Ubuntu | Dyuti OS | `chroot/rebrand.sh` + branding pkg |
| Dynamic MOTD ("Welcome to Ubuntu", news/ads) | on | disabled | `chroot/rebrand.sh` |
| Live session user | `ubuntu` | `dyuti` | `/etc/casper.conf` via `rebrand.sh` |
| Bootloader name (installed) | Ubuntu | Dyuti OS | `GRUB_DISTRIBUTOR` via `rebrand.sh` |
| GRUB menu (live ISO) | — | Dyuti | `build/stages/60-iso.sh` |
| Boot splash (Plymouth) | Ubuntu logo | Dyuti radiance | branding pkg `plymouth/themes/dyuti` |
| Startup splash (login→desktop) | **KDE logo** | Dyuti | look-and-feel `contents/splash/Splash.qml` |
| Login screen (SDDM) | Breeze | Dyuti theme | branding pkg `sddm/themes/dyuti` |
| Menu button icon | KDE start-here | `dyuti-logo` | look-and-feel layout JS |
| Desktop look / colors | Breeze | Dyuti global theme | look-and-feel + color scheme |
| Installer | Debian/Calamares | Dyuti | branding pkg `calamares/branding/dyuti` |
| Wallpaper | Ubuntu/KDE | Dyuti | branding pkg |
| Ubuntu fluff packages | installed | purged (best-effort) | `chroot/rebrand.sh` |

## The one honest caveat

**System Settings → About** (KInfoCenter) shows factual version lines like
"KDE Plasma Version / KDE Frameworks Version". These are *version information*,
not branding, and can't be hidden without patching KInfoCenter source. The OS
identity, logo, and accent there are all Dyuti. If a government/enterprise buyer
requires it fully gone, that's a small source patch we can do later — not needed
for the alpha.

## Verify on a built system
```bash
cat /etc/os-release /etc/lsb-release   # → Dyuti
lsb_release -a                         # → Dyuti
cat /etc/issue                         # → Dyuti OS
grep DISTRIBUTOR /etc/default/grub     # → Dyuti OS
```
