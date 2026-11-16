# LFS 13.1-systemd, Chapter 8.72: Tar 1.35
NAME=tar
VERSION=1.35
TARBALL='tar-1.35.tar.xz'
SUMMARY='Archiving utility'
build() { FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr || return 1; make || return 1; make check; }
package() { make DESTDIR="$PKGDIR" install; }
