# LFS 13.1-systemd, Chapter 8.40: Libtool 2.6.2
# Recipe format v2, built and staged with npskg.

NAME=libtool
VERSION=2.6.2
TARBALL='libtool-2.6.2.tar.xz'
SUMMARY='GNU generic library support script'
SOURCE_MD5=87743862e6cabfb9e76651bc64e31e5c

build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1

    ./configure --prefix=/usr || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/lib/libltdl.a"
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete
    rm -f "$PKGDIR/usr/share/info/dir"
}
