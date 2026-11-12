# LFS 13.1, Chapter 8.8: Xz (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/xz.sh
# Install:  npskg install /sources/pkgs/xz-<version>.npskg   (see below)
#
# Written from the LFS 13.1-systemd (rc1) page for Xz-5.8.3, not the final release
# page; compare with the release page. Built, installed and verified.
#
# - build() runs the test suite (make check); a failure aborts the build.
# - The temporary Xz from chapter 6 is installed and owned by no package, so the
#   install is expected to need --force; back up the files it lists first.
# - If the stage contains usr/lib/liblzma.la, note it: the book removes all .la files
#   in its final "Cleaning Up" step, not here.
_tb=$(tarball_path 'xz-[0-9]*.tar.xz')
_v=${_tb##*/xz-}

NAME=xz
VERSION=${_v%.tar.xz}
TARBALL='xz-[0-9]*.tar.xz'
SUMMARY='XZ and LZMA compression programs and liblzma'
LICENSE='0BSD, GPL-2.0-or-later, LGPL-2.1-or-later (see the package)'

build() {
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/xz-$VERSION
    make
    make check
}

package() {
    make DESTDIR="$PKGDIR" install
}
