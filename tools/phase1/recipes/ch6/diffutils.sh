# LFS chapter 6.6: Diffutils (cross-compiled temporary tool). About 0.1 SBU in the book.
# gl_cv_func_strcasecmp_works: the configure check needs to RUN a test program, which
# is impossible when cross-compiling, so the book supplies the answer. The pages
# written for Glibc 2.44 use "yes" (older 12.x pages used "y"). Compare with the
# 13.1 page (6.6) before running.
TARBALL='diffutils-[0-9]*.tar.*'

build() {
    case "$LFS" in ""|/) echo "diffutils: LFS is not set safely" >&2; exit 1 ;; esac

    ./configure --prefix=/usr                      \
                --host="$LFS_TGT"                  \
                gl_cv_func_strcasecmp_works=yes    \
                --build="$(./build-aux/config.guess)"

    make
    make DESTDIR="$LFS" install

    [ -x "$LFS/usr/bin/diff" ] || { echo "CHECK FAILED: diff missing" >&2; exit 1; }
}
