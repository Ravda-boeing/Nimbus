# LFS 13.1-systemd, Chapter 8.73: Texinfo 7.3
NAME=texinfo
VERSION=7.3
TARBALL='texinfo-7.3.tar.xz'
SUMMARY='Documentation system for software'
build() { ./configure --prefix=/usr || return 1; make || return 1; make check; }
package() { make DESTDIR="$PKGDIR" install || return 1; rm -f "$PKGDIR/usr/share/info/dir"; }
