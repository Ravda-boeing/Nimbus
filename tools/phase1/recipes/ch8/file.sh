# LFS 13.1, Chapter 8.11: File 5.48 (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/file.sh
# Install:  npskg install /sources/pkgs/file-5.48.npskg
#
# Based on the LFS 13.1-systemd release instructions.
# Build and test commands follow the book; installation is staged with DESTDIR
# so npskg can capture the package without modifying the live system.

_tb=$(tarball_path 'file-[0-9]*.tar.gz')
_v=${_tb##*/file-}

NAME=file
VERSION=${_v%.tar.gz}
TARBALL='file-[0-9]*.tar.gz'
SUMMARY='File type identification utility and libmagic library'
LICENSE='BSD-2-Clause'

build() {
    ./configure --prefix=/usr
    make
    make check
}

package() {
    make DESTDIR="$PKGDIR" install
}
