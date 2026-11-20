# LFS 13.1-systemd r13.1-42, Chapter 8.77: systemd 262.2
NAME=systemd
VERSION=262.2
TARBALL='systemd-262.2.tar.gz'
SUMMARY='System and service manager'
# Util-linux is built later in LFS Chapter 8 and itself depends on systemd.
# Do not declare it here, or package installation would form a dependency cycle.
DEPENDS=(meson ninja libcap libxcrypt libffi pcre2 kmod)
MAN_TARBALL='systemd-man-pages-262.2.tar.xz'
build() {
    sed -e 's/GROUP="render"/GROUP="video"/' -e 's/GROUP="sgx", //' -i rules.d/50-udev-default.rules.in || return 1
    meson setup build --prefix=/usr --buildtype=release -D default-dnssec=no -D firstboot=false \
      -D install-tests=false -D ldconfig=false -D sysusers=false -D rpmmacrosdir=no \
      -D homed=disabled -D man=disabled -D mode=release -D pamconfdir=no \
      -D dev-kvm-mode=0660 -D nobody-group=nogroup -D sysupdate=disabled -D ukify=disabled \
      -D docdir=/usr/share/doc/systemd-$VERSION || return 1
    ninja -C build
}
package() {
    DESTDIR="$PKGDIR" ninja -C build install || return 1
    mkdir -p "$PKGDIR/usr/share/man" || return 1
    tar -xf "$(tarball_path "$MAN_TARBALL")" --no-same-owner --strip-components=1 -C "$PKGDIR/usr/share/man"
}
