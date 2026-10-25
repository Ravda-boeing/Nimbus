# LFS chapter 6.5: Coreutils (cross-compiled temporary tool). About 0.3 SBU in the book.
# The newer book pages (Glibc 2.43 and later) start with a sed fix for the
# memchr/bsearch declarations in gnulib's *.in.h headers; without it the build
# can fail against the new Glibc. Compare with the 13.1 page (6.5) before running.
TARBALL='coreutils-[0-9]*.tar.*'

build() {
    case "$LFS" in ""|/) echo "coreutils: LFS is not set safely" >&2; exit 1 ;; esac

    # fixes introduced by glibc-2.43 (find -exec so an empty match can never make sed read stdin)
    find . -name '*.in.h' -exec sed -r '/_GL_EXTERN_C/s/w?memchr|bsearch/(&)/' -i {} +

    ./configure --prefix=/usr                      \
                --host="$LFS_TGT"                  \
                --build="$(build-aux/config.guess)" \
                --enable-install-program=hostname  \
                --enable-no-install-program=kill,uptime

    make
    make DESTDIR="$LFS" install

    # move programs to their final expected locations (some programs hardcode them)
    mv -v "$LFS/usr/bin/chroot"                 "$LFS/usr/sbin"
    mkdir -pv "$LFS/usr/share/man/man8"
    mv -v "$LFS/usr/share/man/man1/chroot.1"    "$LFS/usr/share/man/man8/chroot.8"
    sed -i 's/"1"/"8"/'                         "$LFS/usr/share/man/man8/chroot.8"

    [ -x "$LFS/usr/bin/ls" ]      || { echo "CHECK FAILED: ls missing" >&2; exit 1; }
    [ -x "$LFS/usr/sbin/chroot" ] || { echo "CHECK FAILED: chroot not in usr/sbin" >&2; exit 1; }
}
