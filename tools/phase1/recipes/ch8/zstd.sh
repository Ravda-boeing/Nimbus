# LFS 13.1, Chapter 8: Zstd (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/zstd.sh
# Install:  npskg install /sources/pkgs/zstd-1.5.7.npskg
#
# Based on the LFS 13.1-systemd release instructions.
# Build and test commands follow the book; installation is staged with DESTDIR
# so npskg can capture the package without modifying the live system.

_tb=$(tarball_path 'zstd-[0-9]*.tar.gz')
_v=${_tb##*/zstd-}

NAME=zstd
VERSION=${_v%.tar.gz}
TARBALL='zstd-[0-9]*.tar.gz'
SUMMARY='Zstandard fast compression algorithm and utilities'
LICENSE='BSD-3-Clause'

build() {
    make prefix=/usr
    make check
}

package() {
    make prefix=/usr DESTDIR="$PKGDIR" install
    rm -v "$PKGDIR/usr/lib/libzstd.a"
}
