# LFS 13.1-systemd r13.1-42, Chapter 8.81: Util-linux 2.42.4
NAME=util-linux
VERSION=2.42.4
TARBALL='util-linux-2.42.4.tar.xz'
SUMMARY='Essential Linux system utilities'
DEPENDS=(ncurses systemd)
build() {
    ./configure --bindir=/usr/bin --libdir=/usr/lib --runstatedir=/run --sbindir=/usr/sbin \
      --disable-chfn-chsh --disable-login --disable-nologin --disable-su --disable-setpriv \
      --disable-runuser --disable-pylibmount --disable-liblastlog2 --disable-static \
      --without-python ADJTIME_PATH=/var/lib/hwclock/adjtime --docdir=/usr/share/doc/util-linux-$VERSION || return 1
    make || return 1
    local made_fstab=0 test_status=0
    if [ ! -e /etc/fstab ]; then touch /etc/fstab || return 1; made_fstab=1; fi
    chmod o+x .. || { [ "$made_fstab" -eq 0 ] || rm -f /etc/fstab; return 1; }
    chown -R tester . || { [ "$made_fstab" -eq 0 ] || rm -f /etc/fstab; return 1; }
    su tester -c 'make -k check' || test_status=$?
    [ "$made_fstab" -eq 0 ] || rm -f /etc/fstab || return 1
    return "$test_status"
}
package() { make DESTDIR="$PKGDIR" install; }
