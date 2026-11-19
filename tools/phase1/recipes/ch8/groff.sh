# Nimbus Phase 1, Chapter 8.64: Groff 1.25.0
NAME=groff
VERSION=1.25.0
TARBALL='groff-1.25.0.tar.gz'
SUMMARY='Typesetting system for technical documents'
DEPENDS=(perl)
build() {
    PAGE=A4 ./configure --prefix=/usr || return 1
    make -j1 || return 1

    local check_status=0 failures errors failure_count
    make check || check_status=$?
    if [ "$check_status" -ne 0 ]; then
        failures=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^FAIL:' {} + || true)
        errors=$(find . -type f \( -name test-suite.log -o -name testsuite.log \) \
            -exec grep -h '^ERROR:' {} + || true)
        failure_count=$(printf '%s\n' "$failures" | awk 'NF {n++} END {print n+0}')
        if [ "$failure_count" -eq 1 ] && [[ "$failures" == *neqn-smoke-test.sh* ]] && [ -z "$errors" ]; then
            echo 'Disposition: the sole neqn-smoke-test.sh failure is documented by LFS.'
        else
            printf 'Groff test failures:\n%s\n' "${failures:-<none>}"
            printf 'Groff test errors:\n%s\n' "${errors:-<none>}"
            return "$check_status"
        fi
    fi
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
