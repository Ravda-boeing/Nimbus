# Nimbus

A from-scratch Linux distribution, built the LFS way: custom kernel, our own
init and tools, our own package format, and eventually our own desktop.
Long-term goal: a daily-usable desktop OS in the spirit of Linux Mint.

See `docs/DESIGN.MD` for the plan and `docs/UPDATELOG.md` for the change log
(every change to Nimbus must be logged there).

## Build and run (Linux host)

```bash
sudo apt install build-essential bc flex bison libssl-dev libelf-dev libdw-dev \
                 qemu-system-x86 cpio e2fsprogs

make defconfig     # load kernel-config/nimbus_defconfig into kernel/
make kernel        # build the kernel -> build/bzImage
make run           # build initramfs + rootfs, boot in QEMU
```

No kernel config yet? Create one with:

```bash
cd kernel && make x86_64_defconfig kvm_guest.config && cd ..
make save-defconfig
```

Log in with `nimbus` / `os`. Leave with `power shutdown` (or Ctrl+A then X).

To boot a different kernel (for testing): `NIMBUS_KERNEL=/path/to/kernel make run`

## Layout

| Path | What |
|---|---|
| `kernel/` | Linux 7.2.8 source (not tracked by git) |
| `kernel-config/` | `nimbus_defconfig`, the only kernel file we track |
| `initramfs/` | first-stage init + BusyBox, mounts the real root |
| `rootfs/` | the Nimbus root filesystem |
| `packages/` | `.npskg` packages |
| `tools/` | build scripts (`make` calls these) |
| `tools/phase1/` | scripts and recipes for the LFS-style base system (see `docs/PHASE1.md`) |
| `docs/` | design notes and the update log |
| `attic/` | old from-scratch init/shell experiments, kept for reference |
| `build/` | generated images (not tracked) |

## Phase 1: the LFS-style base system

Phase 1 builds a full toolchain and base system with the LFS 13.1 (systemd)
book, on a loop-mounted build disk at `/mnt/lfs`. Each package is a small
recipe under `tools/phase1/recipes/`, built by `tools/phase1/build-pkg.sh` as the
`lfs` user. Chapters 5 and 6 are built; Chapter 7 is in progress.

**Read `docs/PHASE1.md` before touching `/mnt/lfs`.** It covers recovering after
a reboot (the build disk and chroot mounts do not survive one) and the safety
rules for the chroot steps.

## Known gaps

- Login is hardcoded (`nimbus`/`os`). No real users yet.
- No networking.
