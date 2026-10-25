# LFS 13.1-systemd, Chapter 6.3: Ncurses-6.6
# Build host tic, then cross-compile Ncurses for the temporary LFS system.

TARBALL='ncurses-6.6.tar.gz'

build() {
    case "$LFS" in
        ""|/)
            echo "ncurses: LFS is not set safely" >&2
            exit 1
            ;;
    esac

    : "${LFS_TGT:?ncurses: LFS_TGT is not set}"

    # Build the host-side tic utility, as specified by the LFS book.
    mkdir -v build
    pushd build
        ../configure --prefix="$LFS/tools" AWK=gawk
        make -C include
        make -C progs tic
        install -v progs/tic "$LFS/tools/bin"
    popd

    # Cross-compile the target Ncurses libraries.
    ./configure \
        --prefix=/usr \
        --host="$LFS_TGT" \
        --build="$(./config.guess)" \
        --mandir=/usr/share/man \
        --with-manpage-format=normal \
        --with-shared \
        --without-normal \
        --with-cxx-shared \
        --without-debug \
        --without-ada \
        --disable-stripping \
        AWK=gawk

    make
    make DESTDIR="$LFS" install

    ln -sv libncursesw.so "$LFS/usr/lib/libncurses.so"
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i "$LFS/usr/include/curses.h"
}
