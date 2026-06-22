# Branding package (`dyuti-branding`)

This is the source tree for the branding `.deb`. It is built and installed into
the chroot by `build/stages/40-branding.sh` using `dpkg-deb --build`.

## What it ships

| File | Purpose |
|---|---|
| `usr/share/backgrounds/dyuti/dyuti-default.svg` | Default wallpaper (placeholder — replace with designer art) |
| `etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc` | Sets the default wallpaper for new users |
| `etc/skel/.config/kdeglobals` | Default color scheme / icon theme (Breeze for now) |
| `usr/share/dyuti/issue` | Branded console login banner |
| `usr/lib/os-release` | **Generated at build time** from `build/config.sh` — do not edit by hand |
| `DEBIAN/control`, `DEBIAN/postinst` | Package metadata + post-install (font cache, issue) |

## Where the real polish goes (Month 2)

- Replace `dyuti-default.svg` with the designer's wallpaper set.
- Add a custom Plasma **global theme** under `usr/share/plasma/look-and-feel/`
  and point `kdeglobals` `LookAndFeelPackage` at it.
- Add an icon theme + Plasma color scheme that match the design system.
- Add Calamares branding (logo, slideshow) under `etc/calamares/branding/`.

## Editing safely

Everything is parameterised in `build/config.sh`. Change the name/version there;
do **not** hard-code the brand in this tree (except asset filenames, which you
can rename alongside the paths referenced above).
