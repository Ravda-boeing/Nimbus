# LFS 13.1-systemd, Chapter 8.78: D-Bus 1.16.2
NAME=dbus
VERSION=1.16.2
TARBALL='dbus-1.16.2.tar.xz'
SUMMARY='Desktop and system message bus'
DEPENDS=(meson ninja expat)
build() { meson setup build --prefix=/usr --buildtype=release --wrap-mode=nofallback || return 1; ninja -C build || return 1; ninja -C build test; }
package() { DESTDIR="$PKGDIR" ninja -C build install || return 1; mkdir -p "$PKGDIR/var/lib"; ln -sfv /etc/machine-id "$PKGDIR/var/lib/dbus"; }
