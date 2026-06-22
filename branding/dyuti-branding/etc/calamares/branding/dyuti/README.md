# Dyuti Calamares branding

Branding for the Calamares graphical installer.

- `branding.desc` — product name/version/URLs, sidebar colours, slideshow ref.
- `show.qml` — the install-time slideshow (3 on-brand text slides for now).
- **Add later (designer):** `logo.png` (~80px), `welcome.png` (~64px) in this
  folder — referenced by `branding.desc`.

## How it gets activated
`calamares-settings-debian` ships `/etc/calamares/settings.conf`. We do **not**
overwrite that file (dpkg conflict). Instead the branding package's `postinst`
rewrites its `branding:` line to `dyuti`, so Calamares loads this folder.

Test on a built system: launch `sudo calamares -d` and watch the console.
