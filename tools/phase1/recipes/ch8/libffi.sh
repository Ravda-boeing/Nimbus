# LFS 13.1-systemd, Chapter 8.51: Libffi 3.8.0
NAME=libffi
VERSION=3.8.0
TARBALL='libffi-3.8.0.tar.gz'
SUMMARY='Foreign function interface library'
build() {
    ./configure --prefix=/usr --disable-static --with-gcc-arch=native || return 1
    make || return 1
    make check
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete
}
