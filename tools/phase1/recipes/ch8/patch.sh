# LFS r13.1-42-systemd, Chapter 8.71: Patch 2.8.1
NAME=patch
VERSION=2.8.1
TARBALL='patch-2.8.1.tar.xz'
SUMMARY='Utility for modifying files with patch files'
DEPENDS=(glibc)
SOURCE_MD5=385458c8de6334c36b56ce7fd198411c
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
