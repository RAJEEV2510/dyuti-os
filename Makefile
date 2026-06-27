# Dyuti OS build orchestration.
# All real work lives in build/. The Makefile is just convenient entry points.
# Most targets need root (debootstrap, chroot, mount), hence `sudo make ...`.

SHELL := /bin/bash

.PHONY: build refresh bootstrap configure desktop branding cleanup iso clean reallyclean help

help:
	@echo "Dyuti OS build targets:"
	@echo "  make build       - run the full pipeline -> dist/*.iso"
	@echo "  make refresh     - incremental: reuse chroot, re-brand + repack ISO"
	@echo "  make bootstrap   - stage 10: debootstrap the base system"
	@echo "  make configure   - stage 20: apt sources, locale, mounts"
	@echo "  make desktop     - stage 30: KDE Plasma + apps + languages"
	@echo "  make branding    - stage 40: build + install branding .deb"
	@echo "  make cleanup     - stage 50: shrink chroot, unmount"
	@echo "  make iso         - stage 60: squashfs + hybrid BIOS/UEFI ISO"
	@echo "  make clean       - remove build/work (keep downloaded caches if any)"
	@echo "  make reallyclean - remove build/work and dist"

build:
	@bash build/build.sh all

refresh:
	@bash build/build.sh refresh

bootstrap:
	@bash build/build.sh 10-bootstrap

configure:
	@bash build/build.sh 20-configure

desktop:
	@bash build/build.sh 30-desktop

branding:
	@bash build/build.sh 40-branding

cleanup:
	@bash build/build.sh 50-cleanup

iso:
	@bash build/build.sh 60-iso

clean:
	@bash build/build.sh clean

reallyclean:
	@bash build/build.sh clean
	@rm -rf dist
