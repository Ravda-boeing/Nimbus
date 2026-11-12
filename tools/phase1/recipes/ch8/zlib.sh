# LFS 13.1, Chapter 8.6: Zlib (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/zlib.sh
# Install:  npskg install /sources/pkgs/zlib-<version>.npskg
#
# Written from the LFS 13.1-systemd (rc1) page for Zlib-1.3.2, not the final release
# page; compare with the release page. Built, tested and installed 2026-11-12.
#
# - build() runs the test suite (make check); a failure aborts the build.
# - The book's `rm -fv /usr/lib/libz.a` is done on the stage directory in package().
_tb=$(tarball_path 'zlib-[0-9]*.tar.gz')
_v=${_tb##*/zlib-}

NAME=zlib
VERSION=${_v%.tar.gz}
TARBALL='zlib-[0-9]*.tar.gz'
SUMMARY='Compression and decompression library (libz)'
LICENSE='Zlib'

build() {
    ./configure --prefix=/usr
    make
    make check
}

package() {
    make DESTDIR="$PKGDIR" install
    rm -fv "$PKGDIR/usr/lib/libz.a"
}
