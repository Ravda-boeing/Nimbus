# LFS 13.1-systemd, Chapter 8.29: Libxcrypt 4.5.2
# Recipe format v2, built and staged with npskg.

NAME=libxcrypt
VERSION=4.5.2
TARBALL='libxcrypt-4.5.2.tar.xz'
SUMMARY='Modern password hashing library'
LICENSE='LGPL-2.1-or-later'

build() {
    # Required for compatibility with glibc 2.43 and later.
    sed -i '/strchr/s/const//' lib/crypt-{sm3,gost}-yescrypt.c || return 1

    ./configure --prefix=/usr \
                --enable-hashes=strong,glibc \
                --enable-obsolete-api=no \
                --disable-static \
                --disable-failure-tokens || return 1

    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    find "$PKGDIR/usr/lib" -name '*.la' -delete || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
