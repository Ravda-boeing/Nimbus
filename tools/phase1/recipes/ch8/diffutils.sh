# LFS 13.1-systemd, Chapter 8.62: Diffutils 3.12
NAME=diffutils
VERSION=3.12
TARBALL='diffutils-3.12.tar.xz'
SUMMARY='Utilities for comparing files'
build() { ./configure --prefix=/usr || return 1; make || return 1; make check; }
package() { make DESTDIR="$PKGDIR" install || return 1; rm -f "$PKGDIR/usr/share/info/dir"; }
