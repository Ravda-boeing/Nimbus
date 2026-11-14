# LFS 13.1-systemd, Chapter 8.27: Acl 2.4.0
# Recipe format v2, built and staged with npskg.
# LFS documents test/cp.run as a known failure until Coreutils is rebuilt with ACL support.

NAME=acl
VERSION=2.4.0
TARBALL='acl-2.4.0.tar.xz'
SUMMARY='Utilities and library for access control lists'
LICENSE='GPL-2.0-or-later, LGPL-2.1-or-later'
DEPENDS=(attr)

build() {
    ./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/acl-$VERSION || return 1

    make || return 1

    # The root tests switch to bin/daemon. npskg creates its private build
    # directory mode 0700, so allow search through it without directory listing.
    chmod o+x .. || return 1

    local check_status=0 failures errors
    make check || check_status=$?
    if [ "$check_status" -ne 0 ]; then
        failures=$(find . -type f -name '*.log' -exec grep -h '^FAIL:' {} + | sed 's/^FAIL: //' | sort -u || true)
        errors=$(find . -type f -name '*.log' -exec grep -h '^ERROR:' {} + || true)
        if { [ "$failures" = 'test/cp' ] || [ "$failures" = 'test/cp.run' ]; } && [ -z "$errors" ]; then
            echo 'Accepting the one test/cp.run failure documented by LFS.'
        else
            printf 'Unexpected Acl test result (status %s). Failures:\n%s\nErrors:\n%s\n' \
                "$check_status" "${failures:-<none>}" "${errors:-<none>}" >&2
            return 1
        fi
    fi
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    find "$PKGDIR/usr/lib" -name '*.la' -delete || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
