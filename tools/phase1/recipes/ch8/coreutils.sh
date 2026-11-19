# LFS 13.1-systemd, Chapter 8.61: Coreutils 9.12
NAME=coreutils
VERSION=9.12
TARBALL='coreutils-9.12.tar.xz'
SUMMARY='Basic file, shell, and text utilities'
build() {
    cp "$(tarball_path 'coreutils-9.12-i18n-1.patch')" . || return 1
    patch -Np1 -i coreutils-9.12-i18n-1.patch || return 1
    autoreconf -fv || return 1
    automake -af || return 1
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr || return 1
    make || return 1
    make NON_ROOT_USERNAME=tester check-root || return 1
    groupadd -g 102 dummy -U tester || return 1
    chmod o+x .. || return 1
    chown -R tester . || return 1
    local rc=0
    su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" </dev/null || rc=$?
    groupdel dummy || return 1
    return "$rc"
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    mv "$PKGDIR/usr/bin/chroot" "$PKGDIR/usr/sbin/" || return 1
    mv "$PKGDIR/usr/share/man/man1/chroot.1" "$PKGDIR/usr/share/man/man8/chroot.8" || return 1
    sed -i 's/"1"/"8"/' "$PKGDIR/usr/share/man/man8/chroot.8"
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
