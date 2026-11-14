# LFS 13.1-systemd, Chapter 8.23: GMP 6.3.0
# Recipe format v2, built and staged with npskg.
# The complete make check suite is critical; require the book's minimum 199 passes.

NAME=gmp
VERSION=6.3.0
TARBALL='gmp-6.3.0.tar.xz'
SUMMARY='GNU multiple precision arithmetic library'
LICENSE='LGPL-3.0-or-later, GPL-2.0-or-later'

build() {
    sed -i '/long long t1;/,+1s/()/(...)/' configure || return 1

    ./configure --prefix=/usr \
                --enable-cxx \
                --disable-static \
                --docdir=/usr/share/doc/gmp-$VERSION || return 1

    make || return 1
    make html || return 1
    make check || return 1

    local passed
    passed=$(find . -type f -name '*.log' -exec cat {} + | grep -c '^PASS' || true)
    printf 'GMP test passes: %s\n' "$passed"
    [ "$passed" -ge 199 ] || {
        echo 'GMP test suite did not reach the required 199 passes.' >&2
        return 1
    }
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    make DESTDIR="$PKGDIR" install-html || return 1
    # Glibc owns the shared Info index in Nimbus.
    rm -f "$PKGDIR/usr/share/info/dir"
}
