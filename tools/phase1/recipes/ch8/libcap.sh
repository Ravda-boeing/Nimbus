# LFS 13.1-systemd, Chapter 8.28: Libcap 2.78
# Recipe format v2, built and staged with npskg.

NAME=libcap
VERSION=2.78
TARBALL='libcap-2.78.tar.xz'
SUMMARY='POSIX capabilities library and tools'
LICENSE='BSD-3-Clause, GPL-2.0-or-later'
DEPENDS=(attr)

build() {
    # The book disables installing static libraries.
    sed -i '/install -m.*STA/d' libcap/Makefile || return 1

    make prefix=/usr lib=lib || return 1
    make test
}

package() {
    make prefix=/usr lib=lib DESTDIR="$PKGDIR" install || return 1
    find "$PKGDIR/usr/lib" -name '*.la' -delete || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
