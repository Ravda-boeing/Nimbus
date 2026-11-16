# LFS 13.1-systemd, Chapter 8.60: Kmod 34.2
NAME=kmod
VERSION=34.2
TARBALL='kmod-34.2.tar.xz'
SUMMARY='Kernel module utilities and library'
DEPENDS=(meson ninja)
build() {
    meson setup build --prefix=/usr --buildtype=release -D manpages=false || return 1
    ninja -C build
}
package() { DESTDIR="$PKGDIR" ninja -C build install; }
