# LFS 13.1-systemd, Chapter 8.71: Patch 2.8
NAME=patch
VERSION=2.8
TARBALL='patch-2.8.tar.xz'
SUMMARY='Utility for modifying files with patch files'
build() { ./configure --prefix=/usr || return 1; make || return 1; make check; }
package() { make DESTDIR="$PKGDIR" install || return 1; rm -f "$PKGDIR/usr/share/info/dir"; }
