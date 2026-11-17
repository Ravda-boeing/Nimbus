# LFS 13.1-systemd, Chapter 8.49: OpenSSL 4.0.1
# Recipe format v2, built and staged with npskg.

NAME=openssl
VERSION=4.0.1
TARBALL='openssl-4.0.1.tar.gz'
SUMMARY='Cryptographic management tools and libraries'
DEPENDS=(perl)

build() {
    ./config --prefix=/usr \
             --openssldir=/etc/ssl \
             --libdir=lib \
             shared \
             zlib-dynamic || return 1
    make || return 1
    make test
}

package() {
    make DESTDIR="$PKGDIR" INSTALL_LIBS= MANSUFFIX=ssl install || return 1

    mv -v "$PKGDIR/usr/share/doc/openssl" \
        "$PKGDIR/usr/share/doc/openssl-$VERSION" || return 1
    cp -vfr doc/* "$PKGDIR/usr/share/doc/openssl-$VERSION/" || return 1
}
