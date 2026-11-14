# LFS 13.1-systemd, Chapter 8.25: MPC 1.4.1
# Recipe format v2, built and staged with npskg.

NAME=mpc
VERSION=1.4.1
TARBALL='mpc-1.4.1.tar.xz'
SUMMARY='Multiple-precision complex arithmetic library'
LICENSE='LGPL-3.0-or-later'
DEPENDS=(gmp mpfr)

build() {
    ./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/mpc-$VERSION || return 1

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
