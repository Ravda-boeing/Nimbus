# LFS 13.1-systemd, Chapter 8.41: GDBM 1.26
# Recipe format v2, built and staged with npskg.

NAME=gdbm
VERSION=1.26
TARBALL='gdbm-1.26.tar.gz'
SUMMARY='GNU database manager'
SOURCE_MD5=aaa600665bc89e2febb3c7bd90679115

build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1

    ./configure --prefix=/usr \
                --disable-static \
                --enable-libgdbm-compat || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
    find "$PKGDIR/usr/lib" -type f -name '*.la' -delete || return 1
}
