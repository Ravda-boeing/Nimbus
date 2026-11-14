# LFS 13.1-systemd, Chapter 8.18: Expect 5.45.4
# GCC 15+ compatibility patch and Nimbus package staging.

_patch=$(tarball_path 'expect-5.45.4-gcc15-1.patch')

NAME=expect
VERSION=5.45.4
TARBALL='expect5.45.4.tar.gz'
SUMMARY='Programmed dialogue with interactive programs'
DEPENDS=(tcl)

build() {
    python3 -c 'from pty import spawn; spawn(["echo", "ok"])' || return 1

    patch -Np1 -i "$_patch" || return 1

    ./configure --prefix=/usr           \
                --with-tcl=/usr/lib     \
                --enable-shared         \
                --disable-rpath         \
                --mandir=/usr/share/man \
                --with-tclinclude=/usr/include || return 1

    make || return 1
    make test
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    ln -svf expect5.45.4/libexpect5.45.4.so \
        "$PKGDIR/usr/lib/libexpect5.45.4.so" || return 1
}
