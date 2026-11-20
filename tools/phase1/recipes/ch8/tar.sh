# LFS r13.1-42-systemd, Chapter 8.72: Tar 1.35
NAME=tar
VERSION=1.35
TARBALL='tar-1.35.tar.xz'
SUMMARY='Archiving utility'
DEPENDS=(acl glibc)
SOURCE_MD5=a2d8042658cfd8ea939e6d911eaf4152
PATCH_MD5=dbab49e317105539611866dac5dd54f6
PATCH_FILE='tar-1.35-acl_fix-1.patch'
build() {
    local source_archive patch_file
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1
    patch_file=$(tarball_path "$PATCH_FILE") || return 1
    printf '%s  %s\n' "$PATCH_MD5" "$patch_file" | md5sum -c - || return 1
    cp "$patch_file" . || return 1
    patch -Np1 -i "$PATCH_FILE" || return 1
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr || return 1
    make || return 1
    local check_status=0 failures errors failure_count
    make check > tar-test.log 2>&1 || check_status=$?
    if [ "$check_status" -ne 0 ]; then
        failures=$(
            { grep -hE '^[[:space:]]*[0-9]+: .*FAILED|^FAIL:' tar-test.log tests/testsuite.log 2>/dev/null || true; } |
                sed -E 's/^[[:space:]]*[0-9]+:[[:space:]]*/FAIL: /; s/[[:space:]]+FAILED.*$//' |
                sort -u
        )
        errors=$(
            { grep -hE '^ERROR:' tar-test.log tests/testsuite.log 2>/dev/null || true; } |
                grep -Ev '^ERROR: [0-9]+ tests were run' || true
        )
        failure_count=$(printf '%s\n' "$failures" | awk 'NF {n++} END {print n+0}')
        if [ "$failure_count" -eq 1 ] && [[ "$failures" == *capabilities* ]] && [ -z "$errors" ]; then
            echo 'Disposition: the sole capabilities test failure is documented by LFS when SELinux is unavailable.'
        else
            printf 'Tar test failures:\n%s\n' "${failures:-<none>}"
            printf 'Tar test errors:\n%s\n' "${errors:-<none>}"
            tail -n 80 tar-test.log
            return "$check_status"
        fi
    fi
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    make -C doc DESTDIR="$PKGDIR" install-html docdir=/usr/share/doc/tar-1.35 || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
