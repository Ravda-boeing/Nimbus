# LFS 13.1-systemd, Chapter 8.63: Findutils 4.11.0
NAME=findutils
VERSION=4.11.0
TARBALL='findutils-4.11.0.tar.xz'
SUMMARY='Utilities to find files'
DEPENDS=(glibc)
build() {
    ./configure --prefix=/usr --localstatedir=/var/lib/locate || return 1
    make || return 1
    local check_status=0 failures errors failure_count
    if id tester >/dev/null 2>&1; then
        chmod o+x .. || return 1
        chown -R tester . || return 1
        su tester -c "PATH=$PATH make check -k" || check_status=$?
    else
        make check -k || check_status=$?
    fi
    if [ "$check_status" -ne 0 ]; then
        failures=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^FAIL:' {} + || true)
        errors=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^ERROR:' {} + || true)
        failure_count=$(printf '%s\n' "$failures" | awk 'NF {n++} END {print n+0}')
        if [ "$failure_count" -eq 1 ] && [[ "$failures" == *test-regex-el* ]] && [ -z "$errors" ]; then
            echo 'Disposition: the sole test-regex-el failure is documented by LFS.'
        else
            printf 'Findutils test failures:\n%s\n' "${failures:-<none>}"
            printf 'Findutils test errors:\n%s\n' "${errors:-<none>}"
            return "$check_status"
        fi
    fi
}
package() { make DESTDIR="$PKGDIR" install || return 1; rm -f "$PKGDIR/usr/share/info/dir"; }
