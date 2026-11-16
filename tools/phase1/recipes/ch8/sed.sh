# LFS 13.1-systemd, Chapter 8.34: Sed 4.10
# Recipe format v2, built and staged with npskg.

NAME=sed
VERSION=4.10
TARBALL='sed-4.10.tar.xz'
SUMMARY='Stream editor'
LICENSE='GPL-3.0-or-later'

build() {
    ./configure --prefix=/usr || return 1

    make || return 1
    make html || return 1

    # The test suite runs as tester. Permit traversal through npskg's private
    # build directory, then give tester ownership of the source tree.
    chmod o+x .. || return 1
    chown -R tester . || return 1
    su tester -c "PATH=$PATH make check"
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    # Glibc owns the shared Info directory index; do not package it here.
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
    install -vDm644 doc/sed.html -t "$PKGDIR/usr/share/doc/sed-$VERSION" || return 1
}
