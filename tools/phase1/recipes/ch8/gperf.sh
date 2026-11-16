# LFS 13.1-systemd, Chapter 8.42: Gperf 3.3
# Recipe format v2, built and staged with npskg.

NAME=gperf
VERSION=3.3
TARBALL='gperf-3.3.tar.gz'
SUMMARY='Perfect hash function generator'

build() {
    ./configure --prefix=/usr \
                --docdir=/usr/share/doc/gperf-$VERSION || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
