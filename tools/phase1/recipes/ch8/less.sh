# LFS 13.1-systemd, Chapter 8.45: Less 704
# Recipe format v2, built and staged with npskg.

NAME=less
VERSION=704
TARBALL='less-704.tar.gz'
SUMMARY='Text file viewer'
DEPENDS=(ncurses)

build() {
    ./configure --prefix=/usr --sysconfdir=/etc || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install
}
