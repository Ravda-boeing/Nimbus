# LFS 13.1-systemd, Chapter 8.24: MPFR 4.2.2
# Recipe format v2, built and staged with npskg.
# The MPFR test suite is critical; run the complete make check suite.

NAME=mpfr
VERSION=4.2.2
TARBALL='mpfr-4.2.2.tar.xz'
SUMMARY='Multiple-precision floating-point library'
LICENSE='LGPL-3.0-or-later'
DEPENDS=(gmp)

build() {
    ./configure --prefix=/usr \
                --disable-static \
                --enable-thread-safe \
                --docdir=/usr/share/doc/mpfr-$VERSION || return 1

    make || return 1
    make html || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    make DESTDIR="$PKGDIR" install-html || return 1
    # Glibc owns the shared Info index in Nimbus.
    rm -f "$PKGDIR/usr/share/info/dir"
}
