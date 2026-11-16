# LFS 13.1-systemd, Chapter 8.35: Psmisc 23.7
# Recipe format v2, built and staged with npskg.

NAME=psmisc
VERSION=23.7
TARBALL='psmisc-23.7.tar.xz'
SUMMARY='Utilities for displaying information about running processes'

build() {
    ./configure --prefix=/usr || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
}
