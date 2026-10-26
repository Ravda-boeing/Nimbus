#!/bin/bash
# Nimbus Phase 1: the LFS chroot (book chapter 7).
#
#   tools/phase1/chroot.sh status    what is mounted under $LFS (read-only)
#   tools/phase1/chroot.sh check     is the chapter 7.5/7.6 tree complete? (read-only)
#   tools/phase1/chroot.sh mount     mount the virtual kernel filesystems (book 7.3)
#   tools/phase1/chroot.sh enter     enter the chroot (book 7.4)
#   tools/phase1/chroot.sh umount    unmount them again, in reverse order
#
# DRY_RUN=1 prints every command instead of running it. Use it to read what a
# subcommand will do before it does it.
#
# Commands follow the LFS book (7.3 and 7.4). One addition, marked below:
# "mount --make-rslave" on $LFS/dev, so later mounts inside the chroot cannot
# propagate back to the host's /dev on a systemd host.
set -euo pipefail

LFS="${LFS:-/mnt/lfs}"
die() { echo "chroot.sh: $*" >&2; exit 1; }

case "$LFS" in ""|/) die "LFS must be set to the build mount point (not empty, not /)";; esac

usage() { sed -n '2,15p' "$0"; exit 1; }
cmd="${1:-}"; [ -n "$cmd" ] || usage

run() { if [ -n "${DRY_RUN:-}" ]; then echo "+ $*"; else "$@"; fi; }

# the mounts, in the order the book creates them
mounts=( dev dev/pts dev/shm proc sys run )
is_mounted() { mountpoint -q "$LFS/$1"; }

need_disk() {
    if [ -z "${DRY_RUN:-}" ] && ! mountpoint -q "$LFS"; then
        die "$LFS is not a mount point. Mount the build disk first: tools/phase1/lfs-disk.sh mount"
    fi
}

need_root() {
    if [ "$(id -u)" -ne 0 ] && [ -z "${DRY_RUN:-}" ]; then
        exec sudo LFS="$LFS" TERM="${TERM:-linux}" "$0" "$@"
    fi
}

case "$cmd" in
status)
    echo "LFS = $LFS"
    if mountpoint -q "$LFS"; then echo "build disk: mounted"; else echo "build disk: NOT mounted"; fi
    for m in "${mounts[@]}"; do
        if is_mounted "$m" 2>/dev/null; then printf '  mounted:      %s\n' "$LFS/$m"; else printf '  not mounted:  %s\n' "$LFS/$m"; fi
    done
    ;;

mount)
    need_disk; need_root "$@"
    # book 7.3
    run mkdir -pv "$LFS"/{dev,proc,sys,run}
    if ! is_mounted dev 2>/dev/null || [ -n "${DRY_RUN:-}" ]; then
        run mount -v --bind /dev "$LFS/dev"
        # NIMBUS ADDITION (not in the book): stop later mounts from propagating back to the host
        run mount --make-rslave "$LFS/dev"
    fi
    is_mounted dev/pts 2>/dev/null && [ -z "${DRY_RUN:-}" ] || run mount -vt devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"
    is_mounted proc    2>/dev/null && [ -z "${DRY_RUN:-}" ] || run mount -vt proc proc "$LFS/proc"
    is_mounted sys     2>/dev/null && [ -z "${DRY_RUN:-}" ] || run mount -vt sysfs sysfs "$LFS/sys"
    is_mounted run     2>/dev/null && [ -z "${DRY_RUN:-}" ] || run mount -vt tmpfs tmpfs "$LFS/run"
    # /dev/shm: a symlink on some hosts, a tmpfs mount point on others
    if [ -h "$LFS/dev/shm" ]; then
        run install -v -d -m 1777 "$LFS$(realpath /dev/shm)"
    elif ! is_mounted dev/shm 2>/dev/null || [ -n "${DRY_RUN:-}" ]; then
        run mount -vt tmpfs -o nosuid,nodev tmpfs "$LFS/dev/shm"
    fi
    ;;

enter)
    need_disk; need_root "$@"
    if [ -z "${DRY_RUN:-}" ]; then
        for m in dev dev/pts proc sys run; do
            is_mounted "$m" || die "$LFS/$m is not mounted. Run: tools/phase1/chroot.sh mount"
        done
    fi
    # book 7.4
    run chroot "$LFS" /usr/bin/env -i   \
        HOME=/root                      \
        TERM="${TERM:-linux}"           \
        PS1='(lfs chroot) \u:\w\$ '     \
        PATH=/usr/bin:/usr/sbin         \
        MAKEFLAGS="-j$(nproc)"          \
        TESTSUITEFLAGS="-j$(nproc)"     \
        /bin/bash --login
    ;;

umount)
    need_disk; need_root "$@"
    # reverse order of mounting; never lazy (-l): if something is still using a mount, stop
    for (( i=${#mounts[@]}-1; i>=0; i-- )); do
        m="${mounts[$i]}"
        if [ -n "${DRY_RUN:-}" ] || is_mounted "$m" 2>/dev/null; then
            run umount -v "$LFS/$m" || die "could not unmount $LFS/$m (is a shell still inside the chroot? exit it first)"
        fi
    done
    ;;

check)
    # read-only: compares the tree with book sections 7.5 and 7.6. Uses readlink for
    # symlinks, because absolute links such as /run would resolve on the HOST from here.
    ok=0; bad=0
    good()  { ok=$((ok+1)); }
    miss()  { bad=$((bad+1)); printf 'MISSING: %s\n' "$1"; }
    isdir() { if [ -d "$LFS$1" ]; then good; else miss "$1 (directory)"; fi; }
    mode()  { local got; got=$(stat -c %a "$LFS$1" 2>/dev/null || true); if [ "$got" = "$2" ]; then good; else miss "$1 should have mode $2 (has: ${got:-nothing})"; fi; }

    # 7.5 directories
    dirs=( /boot /home /mnt /opt /srv /etc/opt /etc/sysconfig /lib/firmware /media/floppy /media/cdrom
           /usr/include /usr/src /usr/local/include /usr/local/src /usr/lib/locale
           /usr/local/bin /usr/local/lib /usr/local/sbin )
    for b in /usr /usr/local; do
        for d in color dict doc info locale man misc terminfo zoneinfo; do dirs+=( "$b/share/$d" ); done
        for n in 1 2 3 4 5 6 7 8; do dirs+=( "$b/share/man/man$n" ); done
    done
    for d in cache local log mail opt spool; do dirs+=( "/var/$d" ); done
    for d in color misc locate; do dirs+=( "/var/lib/$d" ); done
    for d in "${dirs[@]}"; do isdir "$d"; done

    # 7.5 links and modes
    for l in "/var/run:/run" "/var/lock:/run/lock"; do
        p=${l%%:*}; t=${l#*:}; got=$(readlink "$LFS$p" 2>/dev/null || true)
        if [ "$got" = "$t" ]; then good; else miss "$p should be a symlink to $t (is: ${got:-not a symlink})"; fi
    done
    isdir /root; mode /root 750
    isdir /tmp; mode /tmp 1777
    isdir /var/tmp; mode /var/tmp 1777

    # 7.5 warning: this directory must NOT exist
    if [ -e "$LFS/usr/lib64" ] || [ -L "$LFS/usr/lib64" ]; then
        bad=$((bad+1)); echo "PROBLEM: $LFS/usr/lib64 exists. The book says it must not. Do not continue until you understand why."
    else good; fi

    # 7.6 files
    for f in /etc/passwd /etc/group /etc/hosts /var/log/btmp /var/log/lastlog /var/log/faillog /var/log/wtmp; do
        if [ -f "$LFS$f" ]; then good; else miss "$f (file)"; fi
    done
    got=$(readlink "$LFS/etc/mtab" 2>/dev/null || true)
    if [ "$got" = "/proc/self/mounts" ]; then good; else miss "/etc/mtab should be a symlink to /proc/self/mounts (is: ${got:-not a symlink})"; fi
    mode /var/log/btmp 600; mode /var/log/lastlog 664
    for u in root tester; do
        if grep -q "^$u:" "$LFS/etc/passwd" 2>/dev/null; then good; else miss "user '$u' in /etc/passwd"; fi
        if grep -q "^$u:" "$LFS/etc/group" 2>/dev/null;  then good; else miss "group '$u' in /etc/group"; fi
    done

    echo "check: $ok OK, $bad problem(s)"
    [ "$bad" -eq 0 ]
    ;;

*)
    usage
    ;;
esac
