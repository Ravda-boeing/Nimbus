# Phase 1 runbook: the LFS-style base system

Phase 1 builds a complete toolchain and base system from source, following the
Linux From Scratch 13.1 book (systemd edition). The book is the authority. Our
recipes are copies of its commands, wrapped so each package builds the same
way. Read this file before touching `/mnt/lfs`.

## Where things live

| What | Where |
|---|---|
| Build disk (16 GB sparse ext4 image) | `~/nimbus-build/lfs.img` |
| Its mount point (called `$LFS`) | `/mnt/lfs` |
| Source tarballs and patches | `$LFS/sources` (96 files from the book's download list) |
| Our runner and recipes, as copied for the `lfs` user | `$LFS/sources/nimbus/` |
| Per-package logs and build times | `$LFS/sources/.logs/` (`<name>.log`, `times.txt`) |
| Work directories (kept only when a build fails, or with `KEEP=1`) | `$LFS/sources/.work/<name>` |
| Scripts and recipes in the repo | `tools/phase1/` and `tools/phase1/recipes/ch5`, `ch6`, `ch7` |

Scripts: `check-host.sh` (is this host able to do an LFS build),
`lfs-disk.sh` (create, mount, unmount, status of the build disk),
`setup-build-env.sh` (LFS chapter 4: directories, the `lfs` user),
`build-pkg.sh` (the runner).

## After a reboot or crash (do this first, every time)

The build disk and the chroot mounts do **not** survive a reboot. The image file
itself is safe.

```bash
cd ~/Desktop/Nimbus
e2fsck -f ~/nimbus-build/lfs.img     # only while it is NOT mounted; answer y to fixes
tools/phase1/lfs-disk.sh mount
export LFS=/mnt/lfs                  # keep the leading slash
ls -l /bin/sh                        # must say bash; if dash: sudo ln -sfv bash /bin/sh
findmnt | grep lfs                   # which mounts exist under /mnt/lfs?
cat $LFS/sources/.logs/times.txt     # what has actually been built
```

If `$LFS/sources` is missing or empty, the disk is not mounted. Check `$LFS`
before blaming anything else (a missing `/` in `export LFS=mnt/lfs` has caused
confusing errors before).

## Building a package (chapters 5 and 6)

The `lfs` user cannot read your home directory, so copy the runner and recipes
next to the sources, then build as `lfs`, inside `tmux`:

```bash
cp -r tools/phase1/build-pkg.sh tools/phase1/recipes $LFS/sources/nimbus/
chmod -R a+rX $LFS/sources/nimbus
tmux
sudo su - lfs
$LFS/sources/nimbus/build-pkg.sh $LFS/sources/nimbus/recipes/ch6/<name>.sh
```

The runner unpacks the tarball, runs the recipe's `build()`, logs to
`$LFS/sources/.logs/<name>.log`, appends the time to `times.txt`, and removes
the work directory on success. If a build fails, ask for the last 30 lines of
its log. It refuses to run as root, with `LFS` unset, or with `LFS=/`.

## Chapter 7 and the chroot: read before running anything

From chapter 7 on, steps run as **root**, with the host's `/dev`, `/proc`,
`/sys` and `/run` mounted into `$LFS`, and inside a `chroot`. A wrong path here
can touch the real Mint system.

- **Before deleting anything under `/mnt/lfs`, run `findmnt | grep lfs`.** If
  there are mounts besides the disk itself (`dev`, `proc`, `sys`, `run`), do
  not `rm -rf` anything: deleting through a bind-mounted `/dev` removes real
  device nodes on the host.
- `sudo umount /mnt/lfs` fails while those mounts exist. That is a safety net,
  not a nuisance. Unmount the inner mounts first.
- Every chapter 7 script must refuse to run unless it is root inside the
  chroot (the existing ones check for `/sources/<tarball>` and `/usr/bin/gcc`,
  which do not exist on the host). Keep that check in new ones.
- Use `tools/phase1/chroot.sh` (subcommands `status`, `check`, `mount`,
  `enter`, `umount`). It reproduces the book's commands from sections 7.3 and
  7.4, and `DRY_RUN=1` prints them without running anything. One addition to the
  book: `mount --make-rslave` on `$LFS/dev`, so mounts made inside the chroot
  cannot propagate back to the host's `/dev` on a systemd host.
  `chroot.sh check` compares the tree with sections 7.5 and 7.6 (read-only) and
  flags a stray `/usr/lib64`, which the book says must not exist.

### Chapter 7 status (as of 2026-10-26, from a read-only look at the tree)

- 7.2 ownership: done (the tree is root-owned).
- 7.3 / 7.4 mounts and chroot: gone after every reboot; use `chroot.sh`.
- 7.5 directories: done except `/root` (mode 0750), which is missing.
  `/tmp` was created by hand (mode 1777, correct). `/var/tmp` was not checked.
  Run `chroot.sh check` for the full list.
- 7.6 essential files: present (`passwd`, `group`, `hosts`, the `mtab` link and the
  four log files with the right modes).
- 7.7 Gettext: installed. 7.8 Bison: installed (not yet in the log).
  7.9 Perl: installed (not yet in the log; verify).
- 7.10 Python, 7.11 Texinfo, 7.12 Util-linux, 7.13 cleanup: not started.

## Build status

One SBU (Standard Build Unit, the book's yardstick) is 81 s on this machine.

| Chapter | Package | Seconds |
|---|---|---|
| 5 | binutils-pass1 | 81 |
| 5 | gcc-pass1 | 1013 |
| 5 | linux-headers | 7 |
| 5 | glibc | 365 |
| 5 | libstdcpp | 79 |
| 6 | m4 | 34 |
| 6 | ncurses | 100 |
| 6 | bash | 47 |
| 6 | coreutils | 92 |
| 6 | diffutils | 35 |
| 6 | file | 24 |
| 6 | findutils | 46 |
| 6 | gawk | 30 |
| 6 | grep | 33 |
| 6 | gzip | 25 |
| 6 | make | 12 |
| 6 | patch | 21 |
| 6 | sed | 31 |
| 6 | tar | 40 |
| 6 | xz | 23 |
| 6 | binutils-pass2 | 114 |
| 6 | gcc-pass2 | 1577 |

## How recipes are written

A recipe is a shell file that sets `TARBALL='<glob>'` and defines `build()`. The
helper `tarball_path '<glob>'` finds any other file in `$LFS/sources`.
Conventions:

- Copy the commands from the book page for that exact package, and say which
  page was used. Pages change between book snapshots; the Coreutils and
  Diffutils fixes (glibc 2.43 and later) did not exist in older books.
- Compare each `configure` line with the book before running.
- Guard against an empty or `/` value of `LFS` in any recipe that uses
  `DESTDIR=$LFS`.
- End with a quick check that the thing you built is really there.
- Assign `$(...)` results in two steps. An error inside a nested `$(...)` is
  swallowed under `set -e`.
- Test recipe mechanics with fake tarballs before the first real run.

Known fragile spot: `binutils-pass2.sh` edits `ltmain.sh` by **line number**
(6031 for Binutils 2.44 and 2.45; the book changes it between versions). If the
line number is wrong, the edit silently does nothing. Check with
`tar -xOf $LFS/sources/binutils-*.tar.xz --wildcards 'binutils-*/ltmain.sh' | sed -n 6031p`:
the printed line should contain `$add_dir`. (Without `--wildcards`, tar prints
nothing and says nothing.)

## Sources

- Book (systemd edition): https://www.linuxfromscratch.org/lfs/view/stable-systemd/
- Package list and checksums: `wget-list-systemd` and `md5sums` from the same
  site (the download is already verified; re-verify with `md5sum -c md5sums`
  in `$LFS/sources`)
- Pages used so far: chapter 5 gcc-pass1, glibc, linux-headers, gcc-libstdc++;
  chapter 6 file, diffutils, coreutils, binutils-pass2, gcc-pass2, make, xz,
  patch, sed, tar (all under the book's `chapterNN/` paths)

## Next

1. Verify the chapter 7 state above, then finish 7.5 and 7.6 as the book says.
2. Build Bison, Perl, Python, Texinfo and Util-linux in the chroot, then do the
   chapter 7 cleanup.
3. Chapter 8: the real base system (many packages; the build disk will need to
   be larger, so plan to enlarge the image before the final GCC build).
4. Chapters 9 to 11: configuration, kernel (use the Nimbus config), bootloader.
