# LFS 13.1-systemd, Chapter 8.33: Ncurses 6.6
# Recipe format v2, built and staged with npskg.
# The LFS test suite can only run after installation; see test/README. Run it
# separately after installing this package, as npskg builds into a private stage.

NAME=ncurses
VERSION=6.6
TARBALL='ncurses-6.6.tar.gz'
SUMMARY='Libraries for terminal-independent character screens'

build() {
    ./configure --prefix=/usr \
                --mandir=/usr/share/man \
                --with-shared \
                --without-debug \
                --without-normal \
                --with-cxx-shared \
                --enable-pc-files \
                --with-pkg-config-libdir=/usr/lib/pkgconfig || return 1

    make || return 1
}

package() {
    make DESTDIR="$PKGDIR" install || return 1

    # Keep the wide-character ABI used by the LFS toolchain.
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i "$PKGDIR/usr/include/curses.h" || return 1

    # Preserve the compatibility links required by the book.
    local lib
    for lib in ncurses form panel menu; do
        ln -sfv "lib${lib}w.so" "$PKGDIR/usr/lib/lib${lib}.so" || return 1
        ln -sfv "${lib}w.pc" "$PKGDIR/usr/lib/pkgconfig/${lib}.pc" || return 1
    done
    ln -sfv libncursesw.so "$PKGDIR/usr/lib/libcurses.so" || return 1

    install -d "$PKGDIR/usr/share/doc" || return 1
    cp -v -R doc -T "$PKGDIR/usr/share/doc/ncurses-$VERSION" || return 1
}
