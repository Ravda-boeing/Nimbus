# LFS 13.1-systemd, Chapter 8.74: Vim 9.2.1025
NAME=vim
VERSION=9.2.1025
TARBALL='vim-9.2.1025.tar.gz'
SUMMARY='Vi-compatible text editor'
build() {
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h || return 1
    ./configure --prefix=/usr || return 1
    make || return 1
    chmod o+x .. || return 1
    chown -R tester . || return 1
    sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak || return 1
    su tester -c 'TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test' &> vim-test.log
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    ln -sfv vim "$PKGDIR/usr/bin/vi" || return 1
    local page
    for page in "$PKGDIR"/usr/share/man/{,*/}man1/vim.1; do
        [ -e "$page" ] || continue
        ln -sfv vim.1 "$(dirname "$page")/vi.1" || return 1
    done
    mkdir -p "$PKGDIR/usr/share/doc"
    ln -sv ../vim/vim92/doc "$PKGDIR/usr/share/doc/vim-$VERSION"
}
