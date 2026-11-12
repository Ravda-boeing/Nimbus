# LFS 13.1, Chapter 8.13: Pcre2 (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/pcre2.sh
# Install:  npskg install /sources/pkgs/pcre2-<version>.npskg
#
# Written from the LFS 13.1 development pages (r13.1 and the systemd view) for Pcre2-10.47,
# not the final release page; compare with the release page. Built, tested and installed 2026-11-13.
#
# - build() runs the test suite (make check); a failure aborts the build.
# - pcre2grep and pcre2test link zlib, bzip2 and readline, which are installed.
# - Deviation from the book: the libtool .la files are not shipped. The book keeps them
#   until its final cleanup, which would then invalidate npskg's file records.
_tb=$(tarball_path 'pcre2-[0-9]*.tar.bz2')
_v=${_tb##*/pcre2-}

NAME=pcre2
VERSION=${_v%.tar.bz2}
TARBALL='pcre2-[0-9]*.tar.bz2'
SUMMARY='Perl Compatible Regular Expression libraries (libpcre2), pcre2grep, pcre2test'
LICENSE='BSD-3-Clause (see the package)'

build() {
    ./configure --prefix=/usr                          \
                --docdir=/usr/share/doc/pcre2-$VERSION \
                --enable-unicode                       \
                --enable-jit                           \
                --enable-pcre2-16                      \
                --enable-pcre2-32                      \
                --enable-pcre2grep-libz                \
                --enable-pcre2grep-libbz2              \
                --enable-pcre2test-libreadline         \
                --disable-static
    make
    make check
}

package() {
    make DESTDIR="$PKGDIR" install
    rm -fv "$PKGDIR"/usr/lib/libpcre2-*.la
}
