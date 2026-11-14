# LFS 13.1, Chapter 8.16: Flex 2.6.4
# Commands follow the 13.0 and older book pages; compare with the 13.1 release page.
# The lex symlinks from the book are created in package(). Recipe format v2, built with npskg.

_tb=$(tarball_path 'flex-[0-9]*.tar.gz')
_v=${_tb##*/flex-}

NAME=flex
VERSION=${_v%.tar.gz}
TARBALL='flex-[0-9]*.tar.gz'
SUMMARY='Fast lexical analyzer generator'
LICENSE='BSD-style'

build() {
    ./configure --prefix=/usr \
                --docdir=/usr/share/doc/flex-$VERSION \
                --disable-static || return 1
    make || return 1
    timeout 3600 make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    ln -sv flex   "$PKGDIR/usr/bin/lex"
    ln -sv flex.1 "$PKGDIR/usr/share/man/man1/lex.1"
    rm -f "$PKGDIR/usr/share/info/dir"
    find "$PKGDIR/usr/lib" -name '*.la' -delete
}
