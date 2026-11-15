# LFS 13.1-systemd, Chapter 8.31: Gawk 5.4.1
# Recipe format v2, built and staged with npskg.

NAME=gawk
VERSION=5.4.1
TARBALL='gawk-5.4.1.tar.xz'
SUMMARY='GNU implementation of the awk text-processing language'

build() {
    sed -i 's/extras//' Makefile.in || return 1

    ./configure --prefix=/usr || return 1
    make || return 1

    # The test suite runs as tester. Permit traversal through npskg's private
    # build directory, then give tester ownership of the source/build tree.
    chmod o+x .. || return 1
    chown -R tester . || return 1
    su tester -c "PATH=$PATH make check"
}

package() {
    make DESTDIR="$PKGDIR" install || return 1

    ln -sv gawk.1 "$PKGDIR/usr/share/man/man1/awk.1" || return 1
    install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} \
        -t "$PKGDIR/usr/share/doc/gawk-$VERSION" || return 1

    rm -f "$PKGDIR/usr/share/info/dir"
}
