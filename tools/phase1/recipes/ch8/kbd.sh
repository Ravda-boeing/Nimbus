# LFS r13.1-42-systemd, Chapter 8.68: Kbd 2.10.0
NAME=kbd
VERSION=2.10.0
TARBALL='kbd-2.10.0.tar.xz'
SUMMARY='Keyboard utilities and keymaps'
DEPENDS=(bash coreutils glibc)
SOURCE_MD5=77ff950dfa4c34fdf41125547bfa831a
PATCH_MD5=f75cca16a38da6caa7d52151f7136895
build() {
    local source_archive patch_file
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1
    patch_file=$(tarball_path 'kbd-2.10.0-backspace-1.patch') || return 1
    printf '%s  %s\n' "$PATCH_MD5" "$patch_file" | md5sum -c - || return 1
    cp "$patch_file" . || return 1
    patch -Np1 -i kbd-2.10.0-backspace-1.patch || return 1
    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure || return 1
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in || return 1
    ./configure --prefix=/usr --datadir=/usr/share --disable-vlock || return 1
    make || return 1
    make check
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir" || return 1
}
