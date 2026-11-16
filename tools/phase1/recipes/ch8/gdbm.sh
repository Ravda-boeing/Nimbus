# LFS 13.1-systemd, Chapter 8.41: GDBM 1.26
# Recipe format v2, built and staged with npskg.

NAME=gdbm
VERSION=1.26
TARBALL='gdbm-1.26.tar.gz'
SUMMARY='GNU database manager'

build() {
    ./configure --prefix=/usr \
                --disable-static \
                --enable-libgdbm-compat || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete
}
