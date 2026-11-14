# LFS 13.1-systemd, Chapter 8.22: Binutils 2.47
# The Chapter 8 Binutils test suite is critical; keep its complete output and
# inspect every FAIL (the book documents one known gprofng-related failure).

NAME=binutils
VERSION=2.47
TARBALL='binutils-2.47.tar.xz'
SUMMARY='GNU assembler, linker, and binary utilities'
DEPENDS=(zlib)
SOURCE_MD5=d772acfbd55a81644e9fe7b8189cd2a5

build() {
    local source_archive check_status=0 failures errors failure_count
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1

    mkdir build || return 1
    cd build || return 1
    ../configure --prefix=/usr \
                 --sysconfdir=/etc \
                 --enable-ld=default \
                 --enable-plugins \
                 --enable-shared \
                 --disable-werror \
                 --enable-64-bit-bfd \
                 --enable-new-dtags \
                 --with-system-zlib \
                 --with-lib-path=/usr/lib \
                 --enable-default-hash-style=gnu || return 1

    make -j1 tooldir=/usr || return 1

    # LFS marks this suite critical and documents one known gprofng failure.
    # Run the complete suite, retain its status and diagnostics, and accept a
    # nonzero result only when the sole FAIL is gprofng-related and there are
    # no ERROR records. All other test failures stop packaging.
    make -k check || check_status=$?
    printf 'Binutils make -k check exit status: %s\n' "$check_status"
    failures=$(find . -type f -name '*.log' -exec grep -H '^FAIL:' {} + || true)
    errors=$(find . -type f -name '*.log' -exec grep -H '^ERROR:' {} + || true)
    find . -type f -name '*.sum' \
        -exec grep -H -E '^# of (expected passes|unexpected failures|expected failures|unsupported tests|tests skipped)' {} + || true
    if [ -n "$failures" ] || [ "$check_status" -ne 0 ]; then
        printf 'Binutils FAIL records:\n%s\n' "${failures:-<none>}"
        printf 'Binutils ERROR records:\n%s\n' "${errors:-<none>}"
        failure_count=$(printf '%s\n' "$failures" | awk 'NF {n++} END {print n+0}')
        if [ "$check_status" -ne 0 ] && [ "$failure_count" -eq 1 ] &&
           [[ "$failures" == *gprofng* ]] && [ -z "$errors" ]; then
            echo 'Disposition: sole gprofng failure is the one documented by LFS.'
        else
            echo 'Unexpected Binutils test result; refusing to package.' >&2
            return 1
        fi
    fi
}

package() {
    make tooldir=/usr DESTDIR="$PKGDIR" install || return 1

    rm -f "$PKGDIR"/usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a || return 1
    rm -rf "$PKGDIR/usr/share/doc/gprofng" || return 1
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
    find "$PKGDIR/usr/lib" -name '*.la' -delete || return 1
}
