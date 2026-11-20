# LFS r13.1-42-systemd, Chapter 8.73: Texinfo 7.3
NAME=texinfo
VERSION=7.3
TARBALL='texinfo-7.3.tar.xz'
SUMMARY='Documentation system for software'
DEPENDS=(perl)
SOURCE_MD5=915a09fcdfc2bf0f5ecf9e556d5698ff
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
    rm -f "$PKGDIR/usr/share/info/dir"
}
