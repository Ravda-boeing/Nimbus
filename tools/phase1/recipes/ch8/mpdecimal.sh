# LFS 13.1-systemd, Chapter 8.53: mpdecimal 4.0.1
NAME=mpdecimal
VERSION=4.0.1
TARBALL='mpdecimal-4.0.1.tar.gz'
SUMMARY='Correctly-rounded decimal floating point library'
build() {
    ./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpdecimal-$VERSION || return 1
    make || return 1
    make check_local
}
package() { make DESTDIR="$PKGDIR" install; }
