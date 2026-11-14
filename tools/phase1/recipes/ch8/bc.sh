# LFS 13.1, Chapter 8.15: Bc 7.0.3
# GCC 16 defaults to C23, where true/false are keywords and bc's token pasting
# breaks (falseUL undeclared), so the book's C standard flag is needed:
# CC='gcc -std=c99'. Compare with the 13.1 release page.
# Recipe format v2, built with npskg.

_tb=$(tarball_path 'bc-[0-9]*.tar.xz')
_v=${_tb##*/bc-}

NAME=bc
VERSION=${_v%.tar.xz}
TARBALL='bc-[0-9]*.tar.xz'
SUMMARY='Arbitrary precision calculator (bc and dc)'
LICENSE='BSD-2-Clause'

build() {
    CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r || return 1
    make || return 1
    timeout 3600 make test
}

package() {
    make DESTDIR="$PKGDIR" install
}
