# LFS 13.1-systemd, Chapter 8.21: Pkgconf 3.0.5
# Meson is unpacked only as the bootstrap helper prescribed by the book; this
# avoids a circular dependency before Meson is installed later in Chapter 8.

NAME=pkgconf
VERSION=3.0.5
TARBALL='pkgconf-3.0.5.tar.xz'
SUMMARY='Library and tool for managing compiler and linker flags'
LICENSE='ISC'
PKGCONF_MD5=18c528161e6b04ae36dc981af8c4d97e
MESON_TARBALL='meson-1.12.0.tar.gz'
MESON_MD5=9f943c267d63016012efcb0f31ecdd7d

build() {
    local pkgconf_archive meson_archive
    pkgconf_archive=$(tarball_path "$TARBALL") || return 1
    meson_archive=$(tarball_path "$MESON_TARBALL") || return 1
    printf '%s  %s\n' "$PKGCONF_MD5" "$pkgconf_archive" | md5sum -c - || return 1
    printf '%s  %s\n' "$MESON_MD5" "$meson_archive" | md5sum -c - || return 1

    tar -xf "$meson_archive" || return 1
    mkdir build || return 1
    cd build || return 1
    python3 ../meson-1.12.0/meson.py setup \
        --prefix=/usr --buildtype=release .. || return 1
    ninja -j2 || return 1
    ninja -j2 test
}

package() {
    DESTDIR="$PKGDIR" ninja install || return 1
    mv "$PKGDIR/usr/share/doc/pkgconf" \
       "$PKGDIR/usr/share/doc/pkgconf-$VERSION" || return 1
    ln -sv pkgconf "$PKGDIR/usr/bin/pkg-config" || return 1
    ln -sv pkgconf.1 "$PKGDIR/usr/share/man/man1/pkg-config.1" || return 1

    rm -f "$PKGDIR/usr/share/info/dir" || return 1
    find "$PKGDIR/usr/lib" -name '*.la' -delete 2>/dev/null || return 1
}
