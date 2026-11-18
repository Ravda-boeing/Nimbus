# LFS 13.1-systemd, Chapter 8.54: Python 3.15.2
NAME=python
VERSION=3.15.2
TARBALL='Python-3.15.2.tar.xz'
SUMMARY='Python programming language runtime'
DEPENDS=(openssl bzip2 expat gdbm libffi libxcrypt mpdecimal ncurses sqlite zlib)
build() {
    ./configure --prefix=/usr --enable-shared --with-system-expat \
      --enable-optimizations --without-static-libpython || return 1
    make || return 1
    make test TESTOPTS='--timeout 120'
}
package() { make DESTDIR="$PKGDIR" install; }
