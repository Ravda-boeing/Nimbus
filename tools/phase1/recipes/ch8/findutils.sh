# LFS 13.1-systemd, Chapter 8.63: Findutils 4.11.0
NAME=findutils
VERSION=4.11.0
TARBALL='findutils-4.11.0.tar.xz'
SUMMARY='Utilities to find files'
build() {
    ./configure --prefix=/usr --localstatedir=/var/lib/locate || return 1
    make || return 1
    chmod o+x .. || return 1
    chown -R tester . || return 1
    su tester -c "PATH=$PATH make check -k"
}
package() { make DESTDIR="$PKGDIR" install || return 1; rm -f "$PKGDIR/usr/share/info/dir"; }
