# LFS 13.1-systemd, Chapter 8.37: Bison 3.8.2
# Recipe format v2, built and staged with npskg.

NAME=bison
VERSION=3.8.2
TARBALL='bison-3.8.2.tar.xz'
SUMMARY='Parser generator'
DEPENDS=(gettext)

build() {
    ./configure --prefix=/usr \
                --docdir=/usr/share/doc/bison-$VERSION || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
