# LFS 13.1-systemd, Chapter 8.50: Libelf from Elfutils 0.197
NAME=libelf
VERSION=0.197
TARBALL='elfutils-0.197.tar.bz2'
SUMMARY='ELF object file handling library'
DEPENDS=(bzip2 xz zlib zstd)
build() {
    ./configure --prefix=/usr --disable-debuginfod --enable-libdebuginfod=dummy || return 1
    make -C lib || return 1
    make -C libelf || return 1
    make -k check
}
package() {
    make -C libelf DESTDIR="$PKGDIR" install || return 1
    install -vDm644 config/libelf.pc "$PKGDIR/usr/lib/pkgconfig/libelf.pc" || return 1
    rm -f "$PKGDIR/usr/lib/libelf.a" || return 1
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete || return 1
}
