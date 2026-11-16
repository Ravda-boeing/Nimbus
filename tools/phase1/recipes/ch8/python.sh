# LFS 13.1-systemd, Chapter 8.54: Python 3.14.7
# Requires the LFS auxiliary patch Python-3.14.7-openssl_4-1.patch.
NAME=python
VERSION=3.14.7
TARBALL='Python-3.14.7.tar.xz'
SUMMARY='Python programming language runtime'
DEPENDS=(openssl bzip2 libffi libxcrypt mpdecimal sqlite zlib)
build() {
    patch -Np1 -i "$(tarball_path 'Python-3.14.7-openssl_4-1.patch')" || return 1
    ./configure --prefix=/usr --enable-shared --with-system-expat \
      --enable-optimizations --without-static-libpython || return 1
    make || return 1
    make test TESTOPTS='--timeout 120'
}
package() { make DESTDIR="$PKGDIR" install; }
