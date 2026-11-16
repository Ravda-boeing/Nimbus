# LFS 13.1-systemd, Chapter 8.64: Groff 1.24.1
NAME=groff
VERSION=1.24.1
TARBALL='groff-1.24.1.tar.gz'
SUMMARY='Typesetting system for technical documents'
DEPENDS=(perl)
build() { PAGE=A4 ./configure --prefix=/usr || return 1; make -j1 || return 1; make check; }
package() { make DESTDIR="$PKGDIR" install; }
