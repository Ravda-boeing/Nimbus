# LFS 13.1-systemd, Chapter 8.39: Bash 5.3
# Recipe format v2, built and staged with npskg.

NAME=bash
VERSION=5.3
TARBALL='bash-5.3.tar.gz'
SUMMARY='The GNU Bourne-Again Shell'
DEPENDS=(readline ncurses)

build() {
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
