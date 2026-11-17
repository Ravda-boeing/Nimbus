# LFS 13.1-systemd, Chapter 8.44: Inetutils 2.8
# Recipe format v2, built and staged with npskg.

NAME=inetutils
VERSION=2.8
TARBALL='inetutils-2.8.tar.gz'
SUMMARY='Basic networking utilities'
DEPENDS=(ncurses)
SOURCE_MD5=f0f9ad13045a67da9c882148f9efae6b

build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1

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
    mv -v "$PKGDIR/usr/bin/ifconfig" "$PKGDIR/usr/sbin/ifconfig" || return 1
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete || return 1
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
