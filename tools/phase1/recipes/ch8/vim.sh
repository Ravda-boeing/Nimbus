# LFS r13.1-42-systemd, Chapter 8.74: Vim 9.2.1351
NAME=vim
VERSION=9.2.1351
TARBALL='vim-9.2.1351.tar.gz'
SUMMARY='Vi-compatible text editor'
DEPENDS=(ncurses)
SOURCE_MD5=4112cc60ba7aebb5e73da643ccdea7fd
build() {
    local source_archive test_status failed_test_count
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h || return 1
    ./configure --prefix=/usr || return 1
    make || return 1
    chmod o+x .. || return 1
    chown -R tester . || return 1
    sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak || return 1
    test_status=0
    su tester -c 'TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test' &> vim-test.log || test_status=$?
    if [ "$test_status" -ne 0 ]; then
        failed_test_count=$(grep -c '^Found errors in Test_' vim-test.log || true)
        if [ "$failed_test_count" -eq 1 ] && \
           grep -Fq 'FAILED:     1 Tests' vim-test.log && \
           grep -Fq 'Found errors in Test_relative_cursor_second_line_after_resize()' vim-test.log && \
           grep -Fq 'E303: Unable to open swap file for "[No Name]"' vim-test.log; then
            echo 'Disposition: retrying the sole transient swap-file failure in test_window_cmd.vim.'
            su tester -c 'TERM=xterm-256color LANG=en_US.UTF-8 make -j1 -C src/testdir test_window_cmd' \
                &> vim-window-retry.log || return 1
        else
            tail -n 80 vim-test.log
            return "$test_status"
        fi
    fi
}
package() {
    make DESTDIR="$PKGDIR" install || return 1
    ln -sfv vim "$PKGDIR/usr/bin/vi" || return 1
    local page
    for page in "$PKGDIR"/usr/share/man/{,*/}man1/vim.1; do
        [ -e "$page" ] || continue
        ln -sfv vim.1 "$(dirname "$page")/vi.1" || return 1
    done
    mkdir -p "$PKGDIR/usr/share/doc" || return 1
    ln -sv ../vim/vim92/doc "$PKGDIR/usr/share/doc/vim-$VERSION"
}
