# NIMBUS - Design Overview

Nimbus is a from-scratch, Linux-kernel-based operating system. It is built the
"Linux From Scratch" way: every piece is compiled and assembled by us rather
than inherited from Debian or Ubuntu. The long-term goal is a desktop OS in the
spirit of Linux Mint. Nimbus is also a multi-year warm-up for a future
full-blown cloud OS that will replace SinkOS.

The project is for learning first. Taking the long road is the point.

## Decision log

- 2026-10-21: Build from scratch (LFS/BLFS style), not as a Debian/Ubuntu
  derivative.

## Components

- Linux kernel 7.2.8, own defconfig (`kernel-config/nimbus_defconfig`)
- Nimbus init (PID 1), currently a shell script with `/etc/init.d` services
- BusyBox for the base userland, to be replaced piece by piece
- `.npskg` package format and package manager (planned)
- Nimbus filesystem layout (`rootfs/`)

## Boot flow (Nimbus 0.1)

1. Kernel loads `initramfs.img` and runs `/init`.
2. `/init` mounts /dev /proc /sys, reads `root=` from the kernel command line,
   mounts the real root at /mnt/root and `switch_root`s into it.
3. `/sbin/init` runs the `/etc/init.d/*` scripts in name order, then starts
   `/bin/login`.

## Roadmap

- **Phase 0 - Foundation.** Working QEMU boot, repo cleanup, build scripts.
- **Phase 1 - Toolchain and base system.** Cross-toolchain (binutils, GCC,
  glibc), then core userland (coreutils, bash, util-linux...), built in a clean
  chroot.
- **Phase 2 - Package manager.** `.npskg` build recipes, dependencies,
  install/remove, file manifests. Needed before most later packages.
- **Phase 3 - System services.** Device management, users and login,
  networking, logging.
- **Phase 4 - Graphics.** Kernel DRM, Mesa, fonts, Xorg or Wayland.
- **Phase 5 - Desktop.** Window manager, toolkit, panel, file manager, settings.
- **Phase 6 - Installer and live ISO.** squashfs live image, bootloader,
  installer.

## Open decisions

- Init system: grow our own, port OpenRC/runit, or use systemd.
- C library: glibc (what desktop software expects) or musl (smaller).

## Hardware targets

TODO: write down the minimum and recommended CPU, GPU, RAM and disk.
