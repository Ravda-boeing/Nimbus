# LFS chapter 6.4: Bash (cross-compiled temporary tool). About 0.5 SBU in the book.
# Checked against the book (6.4): configure uses "sh support/config.guess" because
# config.guess is not executable in the tarball. Compare with the 13.1 page before running.
TARBALL='bash-[0-9]*.tar.*'

build() {
    case "$LFS" in ""|/) echo "bash: LFS is not set safely" >&2; exit 1 ;; esac

    ./configure --prefix=/usr                      \
                --build="$(sh support/config.guess)" \
                --host="$LFS_TGT"                  \
                --without-bash-malloc

    make
    make DESTDIR="$LFS" install

    # programs that use sh for a shell
    ln -sv bash "$LFS/bin/sh"

    [ -x "$LFS/usr/bin/bash" ] || { echo "CHECK FAILED: $LFS/usr/bin/bash missing" >&2; exit 1; }
    [ -L "$LFS/bin/sh" ]       || { echo "CHECK FAILED: $LFS/bin/sh symlink missing" >&2; exit 1; }
}
