# LFS 13.1-systemd, Chapter 8.43: Expat 2.8.3
# Recipe format v2, built and staged with npskg.

NAME=expat
VERSION=2.8.3
TARBALL='expat-2.8.3.tar.xz'
SUMMARY='Stream-oriented XML parser library'

build() {
    ./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/expat-$VERSION || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    install -v -m644 doc/*.{html,css} \
        "$PKGDIR/usr/share/doc/expat-$VERSION/" || return 1
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete
}
