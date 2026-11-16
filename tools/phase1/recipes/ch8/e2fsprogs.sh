# LFS 13.1-systemd, Chapter 8.82: E2fsprogs 1.47.4
NAME=e2fsprogs
VERSION=1.47.4
TARBALL='e2fsprogs-1.47.4.tar.gz'
SUMMARY='Utilities and libraries for ext2, ext3, and ext4 filesystems'
DEPENDS=(util-linux)
build() {
    mkdir -p build && cd build || return 1
    ../configure --prefix=/usr --sysconfdir=/etc --enable-elf-shlibs --disable-libblkid \
      --disable-libuuid --disable-uuidd --disable-fsck || return 1
    make || return 1
    make check
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/lib/libcom_err.a" "$PKGDIR/usr/lib/libe2p.a" \
          "$PKGDIR/usr/lib/libext2fs.a" "$PKGDIR/usr/lib/libss.a"
    gunzip -f "$PKGDIR/usr/share/info/libext2fs.info.gz" || return 1
    install-info --dir-file="$PKGDIR/usr/share/info/dir" \
      "$PKGDIR/usr/share/info/libext2fs.info"
}
