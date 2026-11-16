# LFS 13.1-systemd, Chapter 8.69: Libpipeline 1.5.8
NAME=libpipeline
VERSION=1.5.8
TARBALL='libpipeline-1.5.8.tar.gz'
SUMMARY='Pipeline manipulation library'
build() { ./configure --prefix=/usr || return 1; make; }
package() { make DESTDIR="$PKGDIR" install; }
