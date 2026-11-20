# LFS 13.1-systemd, Chapter 8.79: Man-DB 2.13.1
NAME=man-db
VERSION=2.13.1
TARBALL='man-db-2.13.1.tar.xz'
SUMMARY='Manual page search and display utilities'
DEPENDS=(groff libpipeline gdbm)
build() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/man-db-$VERSION --sysconfdir=/etc \
      --disable-setuid --enable-cache-owner=bin --with-browser=/usr/bin/lynx \
      --with-vgrind=/usr/bin/vgrind --with-grap=/usr/bin/grap || return 1
    make || return 1
    make check
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    # The global Info index is maintained by the system, not this package.
    rm -f "$PKGDIR/usr/share/info/dir"
}
