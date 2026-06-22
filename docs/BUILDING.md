# Building Dyuti OS

You are on Windows. The build runs on **Linux**. Pick one environment, install
the toolchain, then run the pipeline.

## 1. Get a Linux build environment

### Option A — WSL2 (quickest)
```powershell
wsl --install -d Ubuntu-24.04
```
Reboot if prompted, set a username/password, then open the **Ubuntu** terminal.

> WSL2 note: `debootstrap`, `chroot`, and `mksquashfs` work. If stage 60 (ISO
> assembly with loop/EFI images) misbehaves on your WSL kernel, use Option B for
> that step. Everything up to stage 50 is fine on WSL2.

### Option B — Ubuntu 24.04 VM or bare metal (most reliable)
Any VirtualBox/VMware/Hyper-V VM or machine running Ubuntu 24.04.

## 2. Install the toolchain (inside Linux)
```bash
sudo apt update
sudo apt install -y \
  debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin grub-common \
  mtools dosfstools rsync ca-certificates make
```

## 3. Get the code onto Linux
If the repo lives on your Windows drive, access it via `/mnt/d/projects/dyuti-os`
from WSL — **but** building on `/mnt/...` is slow and can hit permission issues.
Prefer copying into the Linux home:
```bash
cp -r /mnt/d/projects/dyuti-os ~/dyuti-os
cd ~/dyuti-os
```

Make sure scripts are LF + executable (they are committed LF via `.gitattributes`):
```bash
find . -name '*.sh' -exec chmod +x {} \;
chmod +x branding/dyuti-branding/DEBIAN/postinst
```

## 4. Build
```bash
sudo make build          # full pipeline → dist/dyuti-0.1-alpha-amd64.iso
```
Or stage by stage (useful while iterating):
```bash
sudo make bootstrap
sudo make configure
sudo make desktop
sudo make branding
sudo make cleanup
sudo make iso
```

## 5. Test the ISO
```bash
sudo apt install -y qemu-system-x86 ovmf
# BIOS boot:
qemu-system-x86_64 -enable-kvm -m 4096 -cdrom dist/dyuti-*.iso
# UEFI boot:
qemu-system-x86_64 -enable-kvm -m 4096 \
  -bios /usr/share/OVMF/OVMF_CODE.fd -cdrom dist/dyuti-*.iso
```

## 6. Iterate
- Change apps → edit `config/package-lists/apps.list`, then `sudo make desktop`
  (you may need `make clean` first for a fully clean rebuild).
- Change the look → edit `branding/`, then `sudo make branding && sudo make iso`.
- Change the name/version/base → edit `build/config.sh` only.

## Troubleshooting
- **`debootstrap: command not found`** → re-run step 2.
- **mount/permission errors** → you must use `sudo`; don't build on `/mnt/d`.
- **`grub-mkstandalone` missing modules** → install `grub-pc-bin` *and*
  `grub-efi-amd64-bin`.
- **ISO won't boot in UEFI** → boot with OVMF (see step 5) to confirm; real
  hardware needs the appended EFI partition, which stage 60 creates.
- **Clean slate** → `sudo make reallyclean`.
