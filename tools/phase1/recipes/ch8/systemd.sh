# LFS 13.1-systemd, Chapter 8.77: systemd 261.2
NAME=systemd
VERSION=261.2
TARBALL='systemd-261.2.tar.gz'
SUMMARY='System and service manager'
DEPENDS=(meson ninja libcap libxcrypt libffi pcre2 util-linux kmod)
build() {
    sed -e 's/GROUP="render"/GROUP="video"/' -e 's/GROUP="sgx", //' -i rules.d/50-udev-default.rules.in || return 1
    meson setup build --prefix=/usr --buildtype=release -D default-dnssec=no -D firstboot=false \
      -D install-tests=false -D ldconfig=false -D sysusers=false -D rpmmacrosdir=no \
      -D homed=disabled -D man=disabled -D mode=release -D pamconfdir=no \
      -D dev-kvm-mode=0660 -D nobody-group=nogroup -D sysupdate=disabled -D ukify=disabled \
      -D docdir=/usr/share/doc/systemd-$VERSION || return 1
    ninja -C build || return 1
    echo 'NAME="Linux From Scratch"' > /etc/os-release
    unshare -m ninja -C build test
}
package() {
    DESTDIR="$PKGDIR" ninja -C build install || return 1
    tar -xf "$(tarball_path "systemd-man-pages-$VERSION.tar.xz")" --no-same-owner --strip-components=1 -C "$PKGDIR/usr/share/man"
}
