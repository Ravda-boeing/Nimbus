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

### 2026-10-04 - Rav
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

Known gaps: plain `poweroff`/`halt` don't work yet (use `power`); login is hardcoded; no networking. (`poweroff`/`halt` fixed in the 2026-10-22 follow-ups entry below.)

Verification and kernel config
- Added `kernel-config/nimbus_defconfig` (x86_64_defconfig + kvm_guest.config, saved with `make savedefconfig`); kernel 7.2.8 builds to `build/bzImage`
- Booted in QEMU on the Nimbus kernel: initramfs -> switch_root -> init.d services -> login (`nimbus`/`os`) -> `nimbus-version`, `nimbus-info`, `nimbus-log` -> `power shutdown` (clean ACPI power-off)
- Known: "can't access tty; job control turned off" appears after login (the `cttyhack` plan did not work; fixed differently in the 2026-10-22 follow-ups entry below)

### 2026-10-22 - Rav
Follow-ups from the first boot test
- `/sbin/init` now stays running as PID 1 and starts `/bin/login` in a loop through `setsid -c` (its own session with a controlling terminal), instead of `exec`ing login: fixes "can't access tty; job control turned off" (job control and Ctrl+C work) and typing `exit` no longer kills init; login restarts after logout
- Added `/sbin/poweroff` and `/sbin/halt` wrappers: plain `poweroff`/`halt`/`reboot` go through `power` (services stop first); the `-f` form goes straight to the kernel, which is what `power` uses
- Added `/etc/nimbus-shrc` (loaded via `ENV` from `/bin/login`): aliases `poweroff`, `halt`, `reboot` to the `/sbin` wrappers, because BusyBox's shell runs its built-in applets before searching PATH

### 2026-10-22 - Rav
Phase 1 prep (LFS-style base system)
- Added `tools/phase1/check-host.sh`: checks the host has what an LFS build needs (tool versions, bash as /bin/sh, gawk, bison as yacc, working compilers, cores/RAM/disk)
- Added `tools/phase1/lfs-disk.sh`: creates, mounts and unmounts a sparse ext4 build disk image at /mnt/lfs (keeps the build off the real partitions)
- Added `tools/phase1/setup-build-env.sh`: LFS chapter 4 (directory layout in /mnt/lfs, `lfs` build user with a clean environment, `sources` directory)

### 2026-10-24 - Rav
Phase 1: first package build tooling
- Added `tools/phase1/build-pkg.sh`: builds one package from a recipe as the `lfs` user (unpacks the tarball from $LFS/sources, runs the recipe's `build()`, logs to $LFS/sources/.logs, records build time in `times.txt`, cleans up on success, keeps the work dir on failure)
- Added `tools/phase1/recipes/ch5/binutils-pass1.sh`: LFS chapter 5.2, Binutils pass 1 (its build time is 1 SBU)

### 2026-10-24 - Rav
Phase 1: Binutils pass 1 built, GCC pass 1 recipe
- Built Binutils pass 1 with `tools/phase1/build-pkg.sh` on the Veriton: 81 s, so 1 SBU = 81 s on this machine
- Added `tools/phase1/recipes/ch5/gcc-pass1.sh`: LFS chapter 5.3, GCC pass 1 (unpacks MPFR/GMP/MPC into the GCC tree, sets the 64-bit lib dir to `lib`, builds the cross compiler, writes the full internal `limits.h`); the Glibc version for `--with-glibc-version` is read from the glibc tarball
- `build-pkg.sh`: added a `tarball_path` helper that recipes can use to locate other source tarballs
- GCC pass 1 built and verified on the Veriton: 1013 s (~12.5 SBU); cross-compiler reports the correct target and successfully compiles a test C file into an x86-64 relocatable object

### 2026-10-25 - Rav
Phase 1: Linux API Headers and Glibc recipes
- Added `tools/phase1/recipes/ch5/linux-headers.sh`: LFS chapter 5.4 (`make mrproper`, `make headers`, strip non-.h files, copy into $LFS/usr)
- Added `tools/phase1/recipes/ch5/glibc.sh`: LFS chapter 5.5, cross-compiled Glibc installed into $LFS (loader symlinks, FHS patch, upstream-fixes patch found by name pattern, `--enable-kernel=5.10`, `ldd` fix, and the book's sanity checks automated: wrong program interpreter or missing new loader fails the build)
- `build-pkg.sh`: refuses to run with LFS set to `/` (the Glibc install would otherwise go onto the host)
- Built Linux API Headers (7 s) and Glibc (365 s) on the Veriton; both passed their checks
- Added `tools/phase1/recipes/ch5/libstdcpp.sh`: LFS chapter 5.6, Libstdc++ from the GCC source tree (GCC version for the include dir is read from the gcc tarball name)

### 2026-10-25 - Rav
Phase 1: Libstdc++ built and verified
- Built and installed Libstdc++ from GCC 16.2.0 using the Phase 1 recipe
- Verified target compiler identity: x86_64-lfs-linux-gnu
- Confirmed target C++ headers and shared/static libraries are installed
- Confirmed libtool archives were removed
- Compiled and linked a C++ test executable against the target sysroot; verified its ELF interpreter and shared-library dependencies
- Ran the test executable on the host successfully; target-root runtime execution remains a separate verification step
- Recorded Libstdc++ build time: 79 seconds

### 2026-10-25 - Rav
Phase 1: Chapter 6.2, M4 built and verified
- Added `tools/phase1/recipes/ch6/m4.sh` for LFS 13.1-systemd Chapter 6.2, M4 1.4.21
- Built and installed M4 using the Phase 1 build runner
- Verified `/mnt/lfs/usr/bin/m4` exists and is executable
- Build log ends with successful installation steps
- Recorded M4 build time: 34 seconds
- Chapter 6 `config.site` setup still needs separate verification (resolved 2026-10-26: nothing to do. The book sets CONFIG_SITE to a path under $LFS on purpose, so the host's /usr/share/config.site is never read; no file has to be created)

### 2026-10-25 - Rav
Phase 1: Chapter 6.3, Ncurses 6.6 built and verified
- Added `tools/phase1/recipes/ch6/ncurses.sh` following LFS 13.1-systemd Chapter 6.3
- Built and installed Ncurses 6.6 using the Phase 1 build runner as the `lfs` user
- Verified the host-side `tic` utility was installed at `/tools/bin/tic`
- Verified target `curses.h` and the `libncurses.so` compatibility symlink
- Build log confirms the terminfo database was installed with 1,861 entries
- Recorded build time: 100 seconds
- Fake-tarball testing was skipped for this recipe; the real build succeeded

### 2026-10-25 - Rav
Phase 1: Chapter 6.4 to 6.7
- Added `tools/phase1/recipes/ch6/{bash,coreutils,diffutils,file}.sh`
- Coreutils includes the glibc-2.43 memchr/bsearch sed fix; Diffutils sets gl_cv_func_strcasecmp_works=yes
- Built on the Veriton: bash 47 s, coreutils 92 s, diffutils 35 s, file 24 s

### 2026-10-25 - Rav
Phase 1: Chapter 6.8 to 6.12
- Added recipes for Findutils 4.11.0, Gawk 5.4.1, Grep 3.12, Gzip 1.14 and Make 4.4.1 (LFS 13.1 systemd)
- Built with the Phase 1 package runner as the `lfs` user: findutils 46 s, gawk 30 s, grep 33 s, gzip 25 s, make 12 s
- Build times and logs are recorded under `$LFS/sources/.logs/`

### 2026-10-25 - Rav
Phase 1: recovery, Chapter 6.13 to 6.16, Binutils pass 2
- Recovered the existing LFS build image after a host crash; the filesystem check completed cleanly
- Built Patch (21 s), Sed (31 s), Tar (40 s) and Xz (23 s)
- Added the Binutils pass 2 recipe and built it (114 s)
- Added the GCC pass 2 recipe; fixed the MPFR, GMP and MPC lookup to use the runner's `tarball_path`

### 2026-10-25 - Rav
Phase 1: GCC pass 2 completed
- GCC pass 2 built in 1577 s (the runner's recorded time)
- Verified /mnt/lfs/usr/bin/gcc and g++ exist and cc links to gcc
- Recovered and remounted the LFS image after a host reboot

### 2026-10-25 - Rav
Phase 1: Chapter 7 start, Gettext
- Recovered the LFS image after a host crash and restored the chroot support mounts (/dev, /dev/pts, /dev/shm, /proc, /sys, /run)
- Added `tools/phase1/recipes/ch7/gettext.sh` (run as root inside the chroot, not through the Chapter 6 runner)
- Created /tmp inside the chroot with mode 1777 after configure could not create a temporary directory
- Built Gettext 1.0 inside the chroot and copied msgfmt, msgmerge and xgettext into /usr/bin; all three verified
- Added `tools/phase1/recipes/ch7/bison.sh` (build not confirmed)

### 2026-10-26 - Rav
Docs tidy-up
- UPDATELOG: removed a duplicated Gettext entry, filled in the missing build times (bash, coreutils, diffutils, file, binutils pass 2), made the headings consistent, and marked three old notes as resolved (the cttyhack plan and the poweroff/halt gap were fixed on 2026-10-22; the Chapter 6 config.site item needs no action)
- DESIGN.MD: roadmap now shows status, decisions recorded (LFS 13.1 systemd edition, glibc), open decisions updated, hardware-targets section rewritten with the build host facts and the questions still to decide
- README.md: added the Phase 1 section and layout rows
- Added `docs/PHASE1.md`, a runbook for the LFS-style build (recovery after a reboot, running a recipe, chroot safety rules, chapter status, lessons learned)

### 2026-10-31 - Rav
Phase 2 design draft
- Added `docs/PACKAGES.md`: draft design for the `.npskg` package manager (recipe vs package, package file layout, installed database, command set, install/remove safety rules, recipe format v2, and when to start tracking: between chapter 7 and chapter 8). Decisions for Rav are marked in the document; nothing is implemented yet
- DESIGN.MD: the Phase 2 roadmap entry now points to it

### 2026-11-02 - Rav
Phase 2: npskg prototype
- Decided (2026-10-31): the package manager is written in Bash, and package tracking starts before chapter 8
- Added `tools/npskg/npskg` v0.1: `build`, `pack`, `install`, `remove`, `list`, `info`, `files`, `owns`, `verify`, with `--root` and `--force`
- Added `tools/npskg/test.sh`: 87 checks, no root needed (installs, dependencies and version constraints, `Provides`/`Conflicts`/`Replaces`, removal, verify, tampered packages, escape through a symlink, script failures, rollback, building from a recipe)
- Found by the tests: GNU tar silently replaces a file with a directory, so `npskg` now refuses any file/directory collision even with `--force`
- Not done: upgrades, config-file handling, converting the Phase 1 recipes to `package()`, running it inside the chroot
- `docs/PACKAGES.md` updated with the decisions and a description of the prototype; DESIGN.MD and README.md point to it

### 2026-11-03 - Rav
Phase 1: Chapter 7 Zlib and mpdecimal
- Added the Zlib 1.3.2 and mpdecimal 4.0.1 Chapter 7 build recipes
- Built and installed both inside the LFS chroot
- Verified their shared libraries with `ldconfig -p` and the installed headers
- Not recorded at the time: why these two were added to chapter 7 (they are not in the chapter 7 list in `docs/PHASE1.md`)

### 2026-11-08 - Rav
Phase 1: Chapter 7 Python
- Added `tools/phase1/recipes/ch7/python.sh` for Python 3.14.7
- Compiled and installed it inside the LFS chroot
- Verified `python3.14 --version` and `python3 --version` both report Python 3.14.7
- Verified `/usr/lib/libpython3.14.so.1.0` exists

### 2026-11-08 - Rav
Phase 1: Chapter 7 Texinfo
- Added `tools/phase1/recipes/ch7/texinfo.sh` for Texinfo 7.3
- Built and installed it inside the LFS chroot
- Verified `makeinfo`, `install-info` and `texindex` all report version 7.3

### 2026-11-08 - Rav
Phase 1: Chapter 7 Util-linux
- Added `tools/phase1/recipes/ch7/util-linux.sh` for Util-linux 2.42.2, following the LFS 13.1-systemd Chapter 7.14 temporary-tools instructions
- Built and installed it inside the LFS chroot
- Verified `mount`, `blkid` and `fdisk` all report Util-linux 2.42.2

### 2026-11-08 - Rav
Docs: bring Phase 1 status up to date
- UPDATELOG: gave the 2026-11-03 and 2026-11-08 entries the same heading style as the rest, and merged the two Util-linux entries into one
- PHASE1.md: rewrote the chapter 7 status (Zlib, mpdecimal, Python, Texinfo and Util-linux are done; cleanup is not started), recorded that Perl and Bison have no verified build in the log, and updated the Next list
- DESIGN.MD and README.md: chapter 7 now shown as nearly done, with only the cleanup remaining
- Open: the Python and Util-linux recipe headers say 7.12 and 7.14, but the status list in PHASE1.md numbers them 7.10 and 7.12; check against the book

### 2026-11-08 - Rav
Phase 1: verified chapter 7 and added a Perl recipe
- Ran `tools/phase1/chroot.sh check` on the Veriton and again on the Aspire after moving the build image there: 84 OK, 0 problems
- Verified inside the chroot: Perl 5.44.0 (prefix `/usr`, `useshrplib` true), Bison 3.8.2, Gettext 1.0 (`msgfmt`), Python 3.14.7, Texinfo 7.3, Util-linux 2.42.2, and the zlib and mpdecimal libraries in `ldconfig -p`
- Perl had been built by hand (`sh Configure -des -D useshrplib`, work directory `/sources/.work/perl-ch7`). Added `tools/phase1/recipes/ch7/perl.sh`, reconstructed from the installed settings; the vendor and sitearch settings still need checking
- Build image: backed up (gzip, tested) to a USB drive, then unpacked onto an ext4 partition on that drive and mounted on the Aspire; `e2fsck` clean
- PHASE1.md: status updated for Perl, Bison and 7.2 to 7.6; section numbers note and Next list updated
