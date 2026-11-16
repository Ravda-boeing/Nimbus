# LFS 13.1-systemd, Chapter 8.36: Gettext 1.0
# Recipe format v2, built and staged with npskg.

NAME=gettext
VERSION=1.0
TARBALL='gettext-1.0.tar.xz'
SUMMARY='Utilities for internationalization and localization'

build() {
    ./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/gettext-$VERSION || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    chmod -v 0755 "$PKGDIR/usr/lib/preloadable_libintl.so" || return 1
    # Do not package the shared Info index; Glibc owns it in the LFS root.
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
