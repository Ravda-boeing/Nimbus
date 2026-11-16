# LFS 13.1-systemd, Chapter 8.47: Autoconf 2.73
# Recipe format v2, built and staged with npskg.

NAME=autoconf
VERSION=2.73
TARBALL='autoconf-2.73.tar.xz'
SUMMARY='Extensible M4-based shell script code generator'

build() {
    ./configure --prefix=/usr || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
