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
| `docs/` | design notes and the update log |
| `attic/` | old from-scratch init/shell experiments, kept for reference |
| `build/` | generated images (not tracked) |

## Known gaps

- Plain `poweroff`/`halt` don't work yet; use `power shutdown`, `power reboot`.
- Login is hardcoded (`nimbus`/`os`). No real users yet.
- No networking.
