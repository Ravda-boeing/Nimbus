# LFS 13.1-systemd, Chapter 8.66: Gzip 1.14
NAME=gzip
VERSION=1.14
TARBALL='gzip-1.14.tar.xz'
SUMMARY='File compression utility'
build() { ./configure --prefix=/usr || return 1; make || return 1; make check; }
package() { make DESTDIR="$PKGDIR" install || return 1; rm -f "$PKGDIR/usr/share/info/dir"; }
