# LFS 13.1-systemd, Chapter 8.19: DejaGNU 1.6.3
# Dedicated build directory and generated HTML/plaintext documentation.

NAME=dejagnu
VERSION=1.6.3
TARBALL='dejagnu-1.6.3.tar.gz'
SUMMARY='GNU testing framework'
DEPENDS=(expect)

build() {
    mkdir -v build || return 1
    cd build || return 1

    ../configure --prefix=/usr || return 1

    makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi || return 1
    makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi || return 1

    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1

    # glibc owns the global Info index in Nimbus; do not ship install-info's
    # staged copy with DejaGNU.
    rm -f "$PKGDIR/usr/share/info/dir" || return 1

    install -v -dm755 "$PKGDIR/usr/share/doc/dejagnu-$VERSION" || return 1
    install -v -m644 doc/dejagnu.html doc/dejagnu.txt \
        "$PKGDIR/usr/share/doc/dejagnu-$VERSION/" || return 1
}
