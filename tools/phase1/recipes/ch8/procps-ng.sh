# LFS 13.1-systemd, Chapter 8.80: Procps-ng 4.0.7
NAME=procps-ng
VERSION=4.0.7
TARBALL='procps-ng-4.0.7.tar.xz'
SUMMARY='Process and system monitoring utilities'
DEPENDS=(ncurses systemd)
build() {
    ./configure --prefix=/usr --docdir=/usr/share/doc/procps-ng-$VERSION \
      --disable-static --disable-kill --enable-watch8bit --with-systemd || return 1
    make || return 1
    chmod o+x .. || return 1
    chown -R tester . || return 1
    su tester -c "PATH=$PATH make check"
}
package() { make DESTDIR="$PKGDIR" install; }
