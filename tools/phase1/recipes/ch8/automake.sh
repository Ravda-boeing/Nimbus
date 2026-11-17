# LFS 13.1-systemd, Chapter 8.48: Automake 1.18.1
# Recipe format v2, built and staged with npskg.

NAME=automake
VERSION=1.18.1
TARBALL='automake-1.18.1.tar.xz'
SUMMARY='Makefile generator for use with Autoconf'
DEPENDS=(autoconf m4 perl)

build() {
    ./configure --prefix=/usr \
                --docdir=/usr/share/doc/automake-$VERSION || return 1
    make || return 1

    # The LFS page uses at least four jobs because many tests have internal delays.
    local jobs
    jobs=$(nproc) || return 1
    [ "$jobs" -ge 4 ] || jobs=4
    make -j"$jobs" check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
