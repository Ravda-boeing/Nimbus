# LFS 13.1-systemd, Chapter 8.61: Coreutils 9.12
NAME=coreutils
VERSION=9.12
TARBALL='coreutils-9.12.tar.xz'
SUMMARY='Basic file, shell, and text utilities'
DEPENDS=(glibc)
build() {
    cp "$(tarball_path 'coreutils-9.12-i18n-1.patch')" . || return 1
    patch -Np1 -i coreutils-9.12-i18n-1.patch || return 1
    autoreconf -fv || return 1
    automake -af || return 1
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr || return 1
    make || return 1

    local check_status=0 failures errors failure_count
    make NON_ROOT_USERNAME=tester check-root || check_status=$?
    if [ "$check_status" -ne 0 ]; then
        failures=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^FAIL:' {} + || true)
        errors=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^ERROR:' {} + || true)
        failure_count=$(printf '%s\n' "$failures" | awk 'NF {n++} END {print n+0}')
        if [ "$failure_count" -eq 1 ] && [[ "$failures" == *test-regex-el* ]] && [ -z "$errors" ]; then
            echo 'Disposition: the sole test-regex-el failure is documented by LFS.'
        else
            printf 'Coreutils root test failures:\n%s\n' "${failures:-<none>}"
            printf 'Coreutils root test errors:\n%s\n' "${errors:-<none>}"
            return "$check_status"
        fi
    fi
    groupadd -g 102 dummy -U tester || return 1
    chmod o+rx .. || return 1
    chown -R tester . || return 1
    check_status=0
    su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" </dev/null || check_status=$?
    groupdel dummy || return 1
    if [ "$check_status" -ne 0 ]; then
        failures=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^FAIL:' {} + | sort -u || true)
        errors=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^ERROR:' {} + || true)
        failure_count=$(printf '%s\n' "$failures" | awk 'NF {n++} END {print n+0}')
        if [ "$failure_count" -eq 1 ] && [[ "$failures" == *test-regex-el* ]] && [ -z "$errors" ]; then
            echo 'Disposition: the sole test-regex-el failure is documented by LFS.'
        else
            printf 'Coreutils test failures:\n%s\n' "${failures:-<none>}"
            printf 'Coreutils test errors:\n%s\n' "${errors:-<none>}"
            return "$check_status"
        fi
    fi
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    mv "$PKGDIR/usr/bin/chroot" "$PKGDIR/usr/sbin/" || return 1
    mv "$PKGDIR/usr/share/man/man1/chroot.1" "$PKGDIR/usr/share/man/man8/chroot.8" || return 1
    sed -i 's/"1"/"8"/' "$PKGDIR/usr/share/man/man8/chroot.8"
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
