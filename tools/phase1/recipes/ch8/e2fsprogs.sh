# LFS 13.1-systemd, Chapter 8.82: E2fsprogs 1.47.4
NAME=e2fsprogs
VERSION=1.47.4
TARBALL='e2fsprogs-1.47.4.tar.gz'
SUMMARY='Utilities and libraries for ext2, ext3, and ext4 filesystems'
DEPENDS=(pkgconf systemd util-linux procps-ng psmisc)
build() {
    mkdir -p build && cd build || return 1
    ../configure --prefix=/usr --sysconfdir=/etc --enable-elf-shlibs --disable-libblkid \
      --disable-libuuid --disable-uuidd --disable-fsck || return 1
    # LFS documents m_assume_storage_prezeroed as a known test failure here.
    # Keep the npskg build/package path usable; run `make check` separately when wanted.
    make
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/lib/libcom_err.a" "$PKGDIR/usr/lib/libe2p.a" \
          "$PKGDIR/usr/lib/libext2fs.a" "$PKGDIR/usr/lib/libss.a" || return 1
    gunzip -f "$PKGDIR/usr/share/info/libext2fs.info.gz" || return 1
    # Keep the global Info index out of the package; glibc owns it in Nimbus.
    rm -f "$PKGDIR/usr/share/info/dir"
}
