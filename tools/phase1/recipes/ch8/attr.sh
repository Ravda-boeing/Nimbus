# LFS 13.1-systemd, Chapter 8.26: Attr 2.6.0
# Recipe format v2, built and staged with npskg.
# The tests require a filesystem with extended attribute support (the LFS image is ext4).

NAME=attr
VERSION=2.6.0
TARBALL='attr-2.6.0.tar.gz'
SUMMARY='Utilities and library for filesystem extended attributes'
LICENSE='GPL-2.0-or-later, LGPL-2.1-or-later'

build() {
    ./configure --prefix=/usr \
                --disable-static \
                --sysconfdir=/etc \
                --docdir=/usr/share/doc/attr-$VERSION || return 1

    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    find "$PKGDIR/usr/lib" -name '*.la' -delete
}
