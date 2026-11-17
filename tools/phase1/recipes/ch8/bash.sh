# LFS 13.1-systemd, Chapter 8.39: Bash 5.3
# Recipe format v2, built and staged with npskg.

NAME=bash
VERSION=5.3
TARBALL='bash-5.3.tar.gz'
SUMMARY='The GNU Bourne-Again Shell'
DEPENDS=(readline ncurses)
SOURCE_MD5=977c8c0c5ae6309191e7768e28ebc951

build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1

    ./configure --prefix=/usr \
                --without-bash-malloc \
                --with-installed-readline \
                --docdir=/usr/share/doc/bash-$VERSION || return 1
    make || return 1

    # Bash's test suite needs a non-root owner and a pseudo-terminal.
    chmod o+x .. || return 1
    chown -R tester . || return 1
    LC_ALL=C.UTF-8 su -s /usr/bin/expect tester <<'EOF'
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    ln -sfv bash "$PKGDIR/usr/bin/sh" || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
