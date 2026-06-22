# Dyuti Plymouth boot theme

Script-module theme: indigo radiance background + a rotating saffron dot ring.

- Works with **no logo** (background + spinner only).
- Drop a `logo.png` (≈400px wide, transparent) into this folder and it appears
  centred automatically — the designer adds this in Month 2.

The branding package's `postinst` registers this theme as the system default
(`update-alternatives --set default.plymouth …`) and rebuilds the initramfs.

Test inside a built system:
```bash
sudo plymouth-set-default-theme -R dyuti
sudo plymouthd ; sudo plymouth show-splash ; sleep 5 ; sudo plymouth quit
```
