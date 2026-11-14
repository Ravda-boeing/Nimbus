# LFS 13.1-systemd, Chapter 8.17: Tcl 8.6.18
# Recipe format v2. Stage normal and private headers through DESTDIR.

_tb=$(tarball_path 'tcl8.6.18-src.tar.gz')
_html=$(tarball_path 'tcl8.6.18-html.tar.gz')

NAME=tcl
VERSION=8.6.18
TARBALL='tcl8.6.18-src.tar.gz'
SUMMARY='Tool Command Language'
LICENSE='Tcl'

build() {
    SRCDIR=$(pwd)
    cd unix || return 1

    ./configure --prefix=/usr \
                --mandir=/usr/share/man \
                --disable-rpath || return 1

    make || return 1

    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|" \
        -i tclConfig.sh || return 1

    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.13|/usr/lib/tdbc1.1.13|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/generic|/usr/include|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/library|/usr/lib/tcl8.6|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13|/usr/include|" \
        -i pkgs/tdbc1.1.13/tdbcConfig.sh || return 1

    sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.7|/usr/lib/itcl4.3.7|" \
        -e "s|$SRCDIR/pkgs/itcl4.3.7/generic|/usr/include|" \
        -e "s|$SRCDIR/pkgs/itcl4.3.7|/usr/include|" \
        -i pkgs/itcl4.3.7/itclConfig.sh || return 1


    LC_ALL=C.UTF-8 timeout 7200 make test
}

package() {
    # build() leaves the shared npskg subshell in src/unix.
    cd .. || return 1
    SRCDIR=$(pwd)
    cd unix || return 1

    make DESTDIR="$PKGDIR" install || return 1
    chmod 644 "$PKGDIR/usr/lib/libtclstub8.6.a" || return 1
    chmod u+w "$PKGDIR/usr/lib/libtcl8.6.so" || return 1

    make DESTDIR="$PKGDIR" install-private-headers || return 1

    ln -sv tclsh8.6 "$PKGDIR/usr/bin/tclsh" || return 1

    mv -v "$PKGDIR/usr/share/man/man3/Thread.3" \
          "$PKGDIR/usr/share/man/man3/Tcl_Thread.3" || return 1

    cd "$SRCDIR" || return 1
    tar -xf "$_html" --strip-components=1 || return 1
    mkdir -p "$PKGDIR/usr/share/doc/tcl-$VERSION" || return 1
    cp -a html/. "$PKGDIR/usr/share/doc/tcl-$VERSION/" || return 1
}
