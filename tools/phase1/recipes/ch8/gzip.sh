# LFS r13.1-42-systemd, Chapter 8.66: Gzip 1.15
NAME=gzip
VERSION=1.15
TARBALL='gzip-1.15.tar.xz'
SUMMARY='File compression utility'
DEPENDS=(bash glibc)
SOURCE_MD5=8b5711442bf246612d0c51de0bf79964
build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1
    ./configure --prefix=/usr || return 1
    make || return 1
    make check
}
package() { make DESTDIR="$PKGDIR" install || return 1; rm -f "$PKGDIR/usr/share/info/dir" || return 1; }
