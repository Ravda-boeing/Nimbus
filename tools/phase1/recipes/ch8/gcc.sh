# LFS 13.1-systemd, Chapter 8.32: GCC 16.2.0
# Recipe format v2, built and staged with npskg.

NAME=gcc
VERSION=16.2.0
TARBALL='gcc-16.2.0.tar.xz'
SUMMARY='GNU compiler collection'
DEPENDS=(binutils gmp mpfr mpc zlib)

build() {
    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 || return 1
            ;;
    esac

    mkdir build || return 1
    cd build || return 1

    ../configure --prefix=/usr \
                 LD=ld \
                 --enable-languages=c,c++ \
                 --enable-default-pie \
                 --enable-default-ssp \
                 --enable-host-pie \
                 --enable-targets=all \
                 --disable-multilib \
                 --disable-bootstrap \
                 --disable-fixincludes \
                 --with-system-zlib || return 1

    make || return 1

    # The LFS test suite needs more than some host default stack limits and
    # runs as tester. Let tester traverse npskg's private work directory.
    ulimit -s -H unlimited || return 1
    chmod o+x ../.. || return 1
    chown -R tester .. || return 1

    # LFS says to continue after test errors and compare the result with its
    # build logs. Preserve make's status, but don't discard the summary or
    # prevent packaging solely because GCC reports its documented failures.
    local check_status=0
    su tester -c "PATH=$PATH make -k check" || check_status=$?
    printf 'GCC make -k check exit status: %s\n' "$check_status"
    ../contrib/test_summary -t || return 1
}

package() {
    make DESTDIR="$PKGDIR" install || return 1

    # Match the Chapter 8 post-install compatibility links in the staged tree.
    ln -svr "$PKGDIR/usr/bin/cpp" "$PKGDIR/usr/lib/cpp" || return 1
    ln -sv gcc.1 "$PKGDIR/usr/share/man/man1/cc.1" || return 1

    local plugin
    plugin=$(find "$PKGDIR/usr/libexec/gcc" "$PKGDIR/usr/lib/gcc" \
        -name liblto_plugin.so -print -quit 2>/dev/null)
    [ -n "$plugin" ] || { echo 'GCC LTO plugin was not installed' >&2; return 1; }
    mkdir -p "$PKGDIR/usr/lib/bfd-plugins" || return 1
    ln -sfvr "$plugin" "$PKGDIR/usr/lib/bfd-plugins/liblto_plugin.so" || return 1

    mkdir -p "$PKGDIR/usr/share/gdb/auto-load/usr/lib" || return 1
    find "$PKGDIR/usr/lib" -maxdepth 1 -name '*gdb.py' -exec mv -v -t \
        "$PKGDIR/usr/share/gdb/auto-load/usr/lib" {} + || return 1

    # GCC installs libtool archives, but the LFS final cleanup deletes them.
    # Exclude them now so npskg's file records remain valid after that cleanup.
    find "$PKGDIR/usr" -type f -name '*.la' -delete || return 1

    rm -f "$PKGDIR/usr/share/info/dir"
}
