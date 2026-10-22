# Update log for Nimbus 
## ANY CHANGES MADE TO NIMBUS MUST BE EXPLICITLY STATED IN THIS DOCUMENT

### 2026-10-03 - Rav
- Initial repo structure
- Added base Makefile
- stubbed init system entry point
- Established dual-version architecture (Linux distro + custom kernel)
- Prepared repo for Nimbus Linux distro development
- Cleaned project structure for userland-only build path
- Added new kernel configuration work for Nimbus (Linux 7.2.8)
- Identified and resolved DWARF dependency issue (libdw-dev)
- Identified Ubuntu/Mint certificate subsystem conflict (canonical-certs.pem)
- Updated kernel configuration to disable trusted keyring and certificate requirements
- Began full kernel build process; halted due to insufficient disk space on Acer device
- Prepared migration plan to continue kernel build on secondary machine with adequate storage
- Added /dev mount support via devtmpfs
- Updated /init to mount /proc and /sys
- Verified BusyBox shell boots cleanly
- Confirmed QEMU boot sequence stable

This will be all I shall do for tonight
I shall resume this tomorrow.
Hopefully you can grasp an understanding on what I'm doing and **HOPEFULLY** one day we could stand at the auditorium presenting Nimbus
but that's for another day
farewell, and good night comrade

### 2026-10-4 - Rav
- Created a clean, minimal Nimbus root filesystem (rootfs/)
- Added BusyBox-based /bin/sh for initial userspace shell
- Implemented first Nimbus /sbin/init with boot banner and shell handoff
- Updated initramfs /init to:
  - mount /dev, /proc, /sys
  - read root= from kernel cmdline
  - mount real rootfs at /mnt/root
  - verify /bin/sh and /sbin/init
  - switch_root into Nimbus userspace
- Completed full boot pipeline for Nimbus 0.1
- Ready to boot Nimbus rootfs in QEMU
- Added init.d scripts: mountfs, banner, network, login
- Implemented Nimbus logging system (var/log/nimbus.log)
- Created Nimbus branding foundation and visual logo concept
- Updated boot sequence messages for consistent Nimbus identity
- Prepared repository for commit and push


### 2026-10-22 - Rav
Phase 0: foundation cleanup. No new features; this makes the boot path match what the code already claims to do.

Repo layout
- Kernel source is no longer tracked in git (`kernel/` is in `.gitignore`); the kernel config is kept as a defconfig in `kernel-config/` instead
- Added top-level `Makefile` and `README.md` (the Makefile mentioned on 2026-10-03 had been lost in the repo cleanup)
- Added `.gitignore` (kernel source, `build/`, `*.img`)
- Moved the old from-scratch init/shell/fs/userland experiments into `attic/`
- Moved `nimbus-tools-0.3.npskg` into `packages/`
- Removed junk placeholder files (`hehe`, `jehe`, `yes`, `:P`, `testing`, `debug.md`) and committed build outputs (`initramfs.img`, `initramfs-nimbus.img`, `rootfs/var/log/nimbus.log`)
- Rewrote `docs/DESIGN.MD` for the from-scratch (LFS-style) direction, with roadmap and open decisions

Boot fixes (rootfs)
- `/bin/login`, `/sbin/power`, `/sbin/reboot` were directories containing the script; they are now plain files
- `/bin/login`, `/sbin/power`, `/sbin/reboot` and the `nimbus-*` tools were not executable; fixed
- Renamed `/bin/sh` to `/bin/busybox`; the shell and all other applets are now symlinks created at build time
- Renamed `Nimbus-*` tools to lowercase to match the help text and package metadata
- Removed `init.d/login` (it exec'd before mountfs/network could run; `sbin/init` already starts login last)
- Removed `init.d/banner` (the banner was printed twice)
- Renamed `init.d/mountfs` to `10-mountfs` and `init.d/network` to `20-network`; removed the duplicated mount block from the network script
- `/sbin/init` now sets PATH explicitly
- `/sbin/power shutdown` now uses `poweroff -f` so the VM actually exits; `/sbin/reboot -f` goes straight to the kernel, plain `reboot` goes through `power`
- `/bin/login` now exports USER, SHELL and HOME
- Added `/etc/nimbus-banner`, `nimbus-motd`, `hostname`, `fstab`, `os-release`

Build tooling
- Added `tools/mkinitramfs.sh`, `tools/mkrootfs.sh` (ext4 image, no root needed), `tools/link-applets.sh`, `tools/run-qemu.sh`

Previously unlogged work (done before today, recorded here)
- `/sbin/power`, `/sbin/reboot`, and the `nimbus-help/info/log/version` tools
- The `nimbus-tools` package skeleton (`.npskg`)

Known gaps: plain `poweroff`/`halt` don't work yet (use `power`); login is hardcoded; no networking.

Verification and kernel config
- Added `kernel-config/nimbus_defconfig` (x86_64_defconfig + kvm_guest.config, saved with `make savedefconfig`); kernel 7.2.8 builds to `build/bzImage`
- Booted in QEMU on the Nimbus kernel: initramfs -> switch_root -> init.d services -> login (`nimbus`/`os`) -> `nimbus-version`, `nimbus-info`, `nimbus-log` -> `power shutdown` (clean ACPI power-off)
- Known: "can't access tty; job control turned off" appears after login (planned fix: start the shell with `cttyhack`)
