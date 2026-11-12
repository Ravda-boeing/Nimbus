# LFS 13.1, Chapter 8.12: Readline 8.3 (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/readline.sh
# Install:  npskg install /sources/pkgs/readline-8.3.npskg
#
# Based on the LFS 13.1-systemd release instructions.
# No test suite is provided by upstream.
# Installation is staged with DESTDIR for npskg.

_tb=$(tarball_path 'readline-[0-9]*.tar.gz')
_v=${_tb##*/readline-}

NAME=readline
VERSION=${_v%.tar.gz}
TARBALL='readline-[0-9]*.tar.gz'
SUMMARY='Command-line editing and history libraries'
LICENSE='GPL-3.0-or-later'

build() {
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
    sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

    sed -e '270a\
else\
  chars_avail = 1;' \
        -e '288i\   result = -1;' \
        -i.orig input.c

    ./configure --prefix=/usr \
                --disable-static \
                --with-curses \
                --docdir=/usr/share/doc/readline-8.3

    make SHLIB_LIBS="-lncursesw"
}

package() {
    make SHLIB_LIBS="-lncursesw" DESTDIR="$PKGDIR" install

    install -v -m644 doc/*.{ps,pdf,html,dvi} \
        "$PKGDIR/usr/share/doc/readline-8.3"
    rm -f "$PKGDIR/usr/share/info/dir"
}
