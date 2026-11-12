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
- Perl had been built by hand (`sh Configure -des -D useshrplib`, work directory `/sources/.work/perl-ch7`). Added `tools/phase1/recipes/ch7/perl.sh`, reconstructed from the installed settings (prefix, vendorprefix, privlib, archlib, sitelib, sitearch, vendorlib, vendorarch and useshrplib all checked with `perl -V:<name>`); not yet compared with the book's page
- Build image: backed up (gzip, tested) to a USB drive, then unpacked onto an ext4 partition on that drive and mounted on the Aspire; `e2fsck` clean
- PHASE1.md: status updated for Perl, Bison and 7.2 to 7.6; section numbers note and Next list updated

### 2026-11-08 - Rav
Phase 1: chapter 7 cleanup recipe
- Added `tools/phase1/recipes/ch7/cleanup.sh` (the "Cleaning" part of the book's section 7.15): removes the installed documentation under `/usr/share/{info,man,doc}`, the libtool `.la` files under `/usr/{lib,libexec}`, and `/tools`
- It refuses to run unless it is root inside a chroot (our `/` must differ from PID 1's), and it checks for `/sources`, gcc and perl first
- The commands come from the LFS 12.4 cleanup page and the book's development source; the 13.1 page has not been compared yet
- Not run yet. The optional "Backup" part of the section is replaced by the gzip backup of the image taken from the host
- PHASE1.md: the 13.1 book numbers this section 7.15, which fits the recipe header numbers (Python 7.12, Texinfo 7.13, Util-linux 7.14)

### 2026-11-08 - Rav
Phase 1: chapter 7 cleanup run, chapter 7 complete
- Ran `recipes/ch7/cleanup.sh` inside the chroot on the Aspire; it finished with "Cleanup Chapter 7 completed."
- Verified afterwards: `/usr/share/doc` and `/usr/share/man` are empty, `/tools` no longer exists, and no `.la` files remain under `/usr/lib` or `/usr/libexec`
- PHASE1.md, DESIGN.MD and README.md now show chapter 7 as done
- Corrected the Perl notes: all Perl paths were checked, not only some of them (the earlier text still said the vendor and sitearch settings needed checking)
- Next: back the image up again, compare the Perl and cleanup recipes with the book's 13.1 pages, then plan chapter 8 (enlarge the image first)

### 2026-11-08 - Rav
Phase 1/2: npskg checked in the chroot, first chapter 8 recipes
- Ran `tools/npskg/test.sh` on the Aspire (87 passed, 0 failed) and again inside the LFS chroot from `/sources/npskg/` (87 passed, 0 failed), so npskg runs with only the chapter 7 tools
- Grew the build image from 16 GB to 30 GB (`truncate`, `e2fsck -f`, `resize2fs`); 4.6 GB used after the cleanup. Backups of the image (gzip, tested) taken before and after the cleanup, kept on the USB drive
- Added `tools/phase1/recipes/ch8/man-pages.sh` and `iana-etc.sh` in recipe format v2 (`package()` installs into the stage directory). Version numbers come from the tarball name in /sources. A dry run with stand-in tarballs built, installed, verified and gave correct ownership; not yet run with the real tarballs
- The Man-pages install command is from the LFS 12.x page and has not been compared with the 13.1 page

### 2026-11-09 - Rav
Phase 1: Glibc recipes written (not run yet)
- Added `tools/phase1/recipes/ch8/glibc.sh` (Glibc 2.44 with the FHS and upstream-fixes patches, the test suite, a staged `DESTDIR` install and the time zone data) and `glibc-config.sh` (the book's `/etc/nsswitch.conf` and `/etc/ld.so.conf`, in a separate package that depends on glibc)
- Written from the LFS development book page for Glibc-2.44 (r13.1-39), not the 13.1 release page; patch and tzdata names match `/sources`
- The test suite runs inside `build()` and does not stop the build on failures; results go to `/sources/.logs/glibc-check.log` and are printed so they can be reviewed before installing
- Installing glibc needs `npskg --force` (the temporary Glibc's files are owned by no package); locales are left for a later glibc-locales recipe
- Dry run of glibc-config with a stand-in glibc package: installs, verifies, files correct. glibc.sh has only had its syntax checked

### 2026-11-09 - Rav
npskg: opt-in build workspace preservation
- Added `NPSKG_KEEP_BUILD=1` to preserve recipe build workspaces after successful or failed builds; default cleanup behaviour is unchanged
- Added tests for default cleanup, successful preservation, failed-build preservation and invalid setting values
- Host test suite: 96 passed, 0 failed
- Documented the setting in PACKAGES.md; the updated script has not yet been copied into the LFS chroot

### 2026-11-09 - Rav
Phase 1: Glibc 2.44 built and tested (not installed yet)
- Built `recipes/ch8/glibc.sh` with npskg on the Aspire and ran the test suite inside `build()` (about 4 hours; the build image is on a USB stick)
- `make check` result: 6772 passed, 8 failed, 579 unsupported, 16 expected failures (7375 outcomes)
- Failing tests: `iconv/tst-iconv_prog`, `iconvdata/tst-e2big`, `io/tst-lchmod`, `stdio-common/tst-fseek-mmap`, `stdio-common/tst-printf-format-d-int`, `stdio-common/tst-printf-format-f-uchar`, `stdlib/test-bz22786`, `timezone/tst-tzset`
- Not yet compared with the book's list of usual failures, so it is not decided whether any of the 8 matter. Glibc has not been installed
- npskg deleted the build workspace after the build, so the per-test `.out` files are gone; this is why `NPSKG_KEEP_BUILD=1` (entry above) was added. The full test log is still in `/sources/.logs/glibc-check.log` on the build image
- glibc.sh header and PHASE1.md updated to say the recipe has now been run
- Copied the updated npskg into the chroot (SHA-256 hashes matched) and ran its tests there: 96 passed, 0 failed (the host suite also passes 96/96)


### 2026-11-10 - Rav
Phase 1: glibc.sh can run selected tests only
- `GLIBC_TESTS="io/tst-lchmod ..."` runs just those tests (log: `/sources/.logs/glibc-tests.log`) instead of the 4-hour full suite; `GLIBC_TIMEOUTFACTOR=10` enlarges timeouts. Meant to be used with `NPSKG_KEEP_BUILD=1` to look into the 8 failures from 2026-11-09
- The full run now uses `make check -k -i`, as the book does
- Not run yet (syntax-checked only)

### 2026-11-10 - Rav (later)
Phase 1: the 8 Glibc test failures investigated
- Rebuilt Glibc with `NPSKG_KEEP_BUILD=1` and ran only the 8 failing tests (`GLIBC_TESTS`); the package went to `/sources/pkgs-debug`, nothing was installed. Host kernel: 7.0.0-38-generic
- Six pass when run on their own: `iconv/tst-iconv_prog`, `iconvdata/tst-e2big`, `stdio-common/tst-fseek-mmap`, `stdio-common/tst-printf-format-d-int`, `stdio-common/tst-printf-format-f-uchar`, `timezone/tst-tzset`. Why they failed inside the full run is not known (their output from that run was lost)
- `io/tst-lchmod` fails because the test sees its open files under a `/mnt/lfs` prefix inside the chroot; this is the book's known chroot failure
- `stdlib/test-bz22786` was killed by the timeout in the full run, but run alone with `TIMEOUTFACTOR=10` it finished in 15 s as UNSUPPORTED ("Heuristically determined OOM termination"). So it was not a speed problem; memory is the likelier cause
- Result: no failure points at a bad Glibc build. Glibc is still not installed


### 2026-11-10 - Rav
Phase 1: Glibc 2.44 installed and verified
- Installed the debug-run Glibc 2.44 package with `npskg --force`; the temporary toolchain's Glibc files were not owned by a package
- Before installation, created and checked `/sources/glibc-pre-install-backup.tar`; its 1465 expected entries matched the archive contents (POSIX ACL support was unavailable)
- Ran `ldconfig` successfully (exit status 0)
- Verified Glibc with npskg: 3469 entries, 0 problems
- Built and installed `glibc-config` 1, providing `/etc/nsswitch.conf` and `/etc/ld.so.conf`; verification: 4 entries, 0 problems
- Both configuration files exist with root ownership and mode 644
- The full test-suite results and investigation of its 8 failures are recorded in the earlier entries above

### 2026-11-12 - Rav
Phase 1: image backup after the Glibc install
- Checked the unmounted build image with `e2fsck -fn`: clean
- Compressed it with `zstd -T0 -3` (30 GiB to 3.48 GiB, about 8 minutes) to `nimbus-backups/lfs-ch8-glibc-installed.img.zst` on the NIMBUS partition; `zstd -t` passed
- It is on the same USB stick as the image, so it does not protect against the stick failing; the stick's NTFS partition has only 2.0G free and the internal Windows partition 6.1G, so a second copy elsewhere is still to do

### 2026-11-12 - Rav (later)
Phase 1: Zlib 1.3.2 built, installed and verified
- Added `recipes/ch8/zlib.sh` (recipe format v2), written from the LFS 13.1-systemd rc1 page for Zlib-1.3.2, not the final release page; the commands are the same as in the 13.0 and 12.4 books
- Built with npskg on the Aspire: `make check` passed (zlib, 64-bit and shared tests OK); package `/sources/pkgs/zlib-1.3.2.npskg`, 14 entries; the static library is removed in the stage, as in the book
- Before installing, saved the six temporary-system files to `/sources/zlib-pre-install-backup.tar`
- The plain install refused because those six files are owned by no package, so it was installed with `npskg --force`
- Verified with npskg: 14 entries, 0 problems; `ldconfig` ran with exit status 0 and `libz.so.1` is in its cache
- Also compiled and ran a small C program against the installed library with `-lz`: it printed `zlib 1.3.2: hello zlib` and linked `/usr/lib/libz.so.1`. (`gzip` does not use Zlib, so it is not a test of it)
