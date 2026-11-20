# LFS r13.1-42-systemd, Chapter 8.70: Make 4.4.1
NAME=make
VERSION=4.4.1
TARBALL='make-4.4.1.tar.gz'
SUMMARY='GNU build automation tool'
DEPENDS=(glibc)
SOURCE_MD5=c8469a3713cbbe04d955d4ae4be23eeb
build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1
    ./configure --prefix=/usr || return 1
    make || return 1
    chmod o+rx .. || return 1
    chown -R tester . || return 1
    su tester -c "PATH=\$PATH make check" </dev/null
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
