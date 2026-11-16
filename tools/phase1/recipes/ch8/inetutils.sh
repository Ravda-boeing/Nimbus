# LFS 13.1-systemd, Chapter 8.44: Inetutils 2.8
# Recipe format v2, built and staged with npskg.

NAME=inetutils
VERSION=2.8
TARBALL='inetutils-2.8.tar.xz'
SUMMARY='Basic networking utilities'

build() {
    sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c || return 1

    ./configure --prefix=/usr \
                --bindir=/usr/bin \
                --localstatedir=/var \
                --disable-logger \
                --disable-whois \
                --disable-rcp \
                --disable-rexec \
                --disable-rlogin \
                --disable-rsh \
                --disable-servers || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    install -vd "$PKGDIR/usr/sbin" || return 1
    mv -v "$PKGDIR/usr/bin/ifconfig" "$PKGDIR/usr/sbin/ifconfig"
}
