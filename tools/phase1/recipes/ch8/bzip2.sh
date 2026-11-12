# LFS 13.1, Chapter 8.7: Bzip2 (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/bzip2.sh
# Install:  npskg install /sources/pkgs/bzip2-<version>.npskg
#
# Written from the LFS development book (r13.1-19) page for Bzip2-1.0.8, not the 13.1
# release page; compare with the release page. Built, tested and installed 2026-11-12.
#
# - build() applies the docs patch, makes the two Makefile seds (relative symlinks and
#   man page location), builds the shared library, then the programs; the final `make`
#   runs the package's tests and a failure aborts the build.
# - package() installs into the stage directory and does the book's shared-library
#   steps there, including the libbz2.so.1 compatibility symlink and removing libbz2.a.
_tb=$(tarball_path 'bzip2-[0-9]*.tar.gz')
_v=${_tb##*/bzip2-}

NAME=bzip2
VERSION=${_v%.tar.gz}
TARBALL='bzip2-[0-9]*.tar.gz'
SUMMARY='Block-sorting file compressor (bzip2, libbz2)'
LICENSE='bzip2-1.0.6'

build() {
    local S=${NPSKG_SOURCES:-/sources}
    patch -Np1 -i "$S/bzip2-1.0.8-install_docs-1.patch"
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

    make -f Makefile-libbz2_so
    make clean
    make
}

package() {
    make PREFIX="$PKGDIR/usr" install

    cp -av libbz2.so.* "$PKGDIR/usr/lib/"
    ln -sfv libbz2.so.1.0.8 "$PKGDIR/usr/lib/libbz2.so"
    ln -sfv libbz2.so.1.0.8 "$PKGDIR/usr/lib/libbz2.so.1"

    cp -v bzip2-shared "$PKGDIR/usr/bin/bzip2"
    for i in "$PKGDIR"/usr/bin/{bzcat,bunzip2}; do
        ln -sfv bzip2 "$i"
    done

    rm -fv "$PKGDIR/usr/lib/libbz2.a"
}
