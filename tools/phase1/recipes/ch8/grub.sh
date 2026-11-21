# LFS 13.1-systemd, Chapter 8.65: GRUB 2.14
NAME=grub
VERSION=2.14
TARBALL='grub-2.14.tar.xz'
SUMMARY='GRand Unified Bootloader'
DEPENDS=(gettext)
build() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    # Work around the 2.14 linker option probe documented by the LFS page.
    sed 's/--image-base/--nonexist-linker-option/' -i configure || return 1
    ./configure --prefix=/usr --sysconfdir=/etc --target=x86_64 \
      --with-platform=efi --disable-efiemu --disable-werror || return 1
    make
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    # The shared Info index is owned by glibc in the LFS system.
    rm -f "$PKGDIR/usr/share/info/dir"
}
