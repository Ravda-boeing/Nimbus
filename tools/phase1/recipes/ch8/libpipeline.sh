# LFS r13.1-42-systemd, Chapter 8.69: Libpipeline 1.5.8
NAME=libpipeline
VERSION=1.5.8
TARBALL='libpipeline-1.5.8.tar.gz'
SUMMARY='Pipeline manipulation library'
DEPENDS=(glibc)
SOURCE_MD5=17ac6969b2015386bcb5d278a08a40b5
build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1
    ./configure --prefix=/usr || return 1
    make
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
