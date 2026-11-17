# LFS 13.1-systemd, Chapter 8.43: Expat 2.8.3
# Recipe format v2, built and staged with npskg.

NAME=expat
VERSION=2.8.3
TARBALL='expat-2.8.3.tar.xz'
SUMMARY='Stream-oriented XML parser library'
SOURCE_MD5=1747f5a57b191f0373baeb5adc8078ca

build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1

    ./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/expat-$VERSION || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    mkdir -p "$PKGDIR/usr/share/doc/expat-$VERSION" || return 1
    install -v -m644 doc/*.{html,css} \
        "$PKGDIR/usr/share/doc/expat-$VERSION/" || return 1
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete || return 1
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
