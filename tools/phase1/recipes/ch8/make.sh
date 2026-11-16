# LFS 13.1-systemd, Chapter 8.70: Make 4.4.1
NAME=make
VERSION=4.4.1
TARBALL='make-4.4.1.tar.gz'
SUMMARY='GNU build automation tool'
build() {
    ./configure --prefix=/usr || return 1
    make || return 1
    chmod o+x .. || return 1
    chown -R tester . || return 1
    su tester -c "PATH=\$PATH make check"
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
