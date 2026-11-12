# LFS 13.1, Chapter 8: Lz4 (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/lz4.sh
# Install:  npskg install /sources/pkgs/lz4-1.10.0.npskg
#
# Based on the LFS 13.1-systemd release instructions.
# Build and test commands follow the book; installation is staged with DESTDIR
# so npskg can capture the package without modifying the live system.

_tb=$(tarball_path 'lz4-[0-9]*.tar.gz')
_v=${_tb##*/lz4-}

NAME=lz4
VERSION=${_v%.tar.gz}
TARBALL='lz4-[0-9]*.tar.gz'
SUMMARY='LZ4 fast compression algorithm and utilities'
LICENSE='BSD-2-Clause'

build() {
    make BUILD_STATIC=no PREFIX=/usr
    make -j1 check
}

package() {
    make BUILD_STATIC=no PREFIX=/usr DESTDIR="$PKGDIR" install
}
