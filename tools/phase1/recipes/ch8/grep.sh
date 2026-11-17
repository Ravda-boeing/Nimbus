# LFS 13.1-systemd, Chapter 8.38: Grep 3.12
# Recipe format v2, built and staged with npskg.

NAME=grep
VERSION=3.12
TARBALL='grep-3.12.tar.xz'
SUMMARY='Programs for searching through the contents of files'
SOURCE_MD5=5d9301ed9d209c4a88c8d3a6fd08b9ac

build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1

    sed -i 's/echo/#echo/' src/egrep.sh || return 1
    ./configure --prefix=/usr || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
