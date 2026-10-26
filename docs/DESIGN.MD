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
- 2026-10-22: Phase 1 follows the LFS 13.1 **systemd** edition. Chosen as the
  default because Mint-style desktops assume systemd; not yet confirmed as the
  long-term choice (see Open decisions).
- 2026-10-22: C library is **glibc**, as in LFS. musl is not planned.

## Components

- Linux kernel 7.2.8, own defconfig (`kernel-config/nimbus_defconfig`)
- Nimbus 0.1 init (PID 1): a shell script with `/etc/init.d` services, on a
  BusyBox rootfs. This is the small system that boots in QEMU today.
- The LFS-style base system, built in Phase 1 under `/mnt/lfs` (see
  `docs/PHASE1.md`). It will replace the BusyBox rootfs.
- `.npskg` package format and package manager (planned)
- Nimbus filesystem layout (`rootfs/`)

## Boot flow (Nimbus 0.1, BusyBox rootfs)

1. Kernel loads `initramfs.img` and runs `/init`.
2. `/init` mounts /dev /proc /sys, reads `root=` from the kernel command line,
   mounts the real root at /mnt/root and `switch_root`s into it.
3. `/sbin/init` runs the `/etc/init.d/*` scripts in name order, then keeps
   running as PID 1 and starts `/bin/login` in its own session, restarting it
   after every logout.

## Roadmap and status

- **Phase 0 - Foundation.** Working QEMU boot, repo cleanup, build scripts.
  *Done.*
- **Phase 1 - Toolchain and base system** (LFS 13.1 systemd). *In progress.*
  - Chapter 5, cross-toolchain: done.
  - Chapter 6, cross-compiled temporary tools: done.
  - Chapter 7, chroot and more temporary tools: started (Gettext built;
    Bison, Perl, Python, Texinfo, Util-linux and cleanup remaining).
  - Chapters 8 to 11, the real base system, configuration, kernel and
    bootloader: not started.
- **Phase 2 - Package manager.** `.npskg` build recipes, dependencies,
  install/remove, file manifests. Needed before most later packages.
- **Phase 3 - System services.** Device management, users and login,
  networking, logging.
- **Phase 4 - Graphics.** Kernel DRM, Mesa, fonts, Xorg or Wayland.
- **Phase 5 - Desktop.** Window manager, toolkit, panel, file manager, settings.
- **Phase 6 - Installer and live ISO.** squashfs live image, bootloader,
  installer.

## Open decisions

- Init system: Phase 1 uses systemd (LFS systemd edition). Keep it long term,
  or write/port something else later (our own init, OpenRC, runit)? Decide
  before Phase 3.
- Package manager design: format of `.npskg`, how dependencies and file
  manifests are tracked, how it relates to the Phase 1 recipes.
- Whether the Phase 1 recipes become the source of truth for the package
  manager, or are only the bootstrap.

## Hardware targets

Not decided yet. Facts so far:

- Build and test host: Acer Veriton X4620G, Intel Core i5-3470 (4 cores),
  about 7 GB RAM, Linux Mint 22 (Ubuntu 24.04 base). A first-time LFS-style
  build here takes a few hours of CPU time in total (GCC pass 1 took about 17
  minutes, GCC pass 2 about 26).
- Nimbus boots as a virtual machine under QEMU (virtio disk, serial console).

To decide, and then write down here:

- Minimum CPU generation and architecture features (x86_64 only?).
- GPU: which drivers are in scope for Phase 4.
- UEFI only, or BIOS as well?
- Minimum RAM and disk for the installed system.
