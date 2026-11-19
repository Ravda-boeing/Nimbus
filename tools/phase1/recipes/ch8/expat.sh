# LFS 13.1-systemd, Chapter 8.43: Expat 2.10.0
# Recipe format v2, built and staged with npskg.

NAME=expat
VERSION=2.10.0
TARBALL='expat-2.10.0.tar.xz'
SUMMARY='Stream-oriented XML parser library'
SOURCE_SHA256=c624ba2998fc65df1163a49641ff3f9ab73138b11641d92c86bee0fb01b1bc7f

build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_SHA256" "$source_archive" | sha256sum -c - || return 1

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
