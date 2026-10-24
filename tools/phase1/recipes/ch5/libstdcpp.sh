# LFS chapter 5.6: Libstdc++ from GCC (the C++ standard library for the target).
# Built from the GCC source tree you already have. Required disk space: 1.5 GB.
#
# Checked against the 13.1 book page (5.6, Libstdc++ from GCC-16.2.0). The GCC
# version in --with-gxx-include-dir is read from the gcc tarball name.
# The final "rm" uses -f (the book uses plain rm -v): the goal is that these
# libtool archives do not exist afterwards, and some may not be created by every
# GCC version.
TARBALL='gcc-[0-9]*.tar.xz'

build() {
    local g gv

    case "$LFS" in ""|/) echo "libstdcpp: LFS is not set safely" >&2; exit 1 ;; esac

    g=$(tarball_path 'gcc-[0-9]*.tar.xz')
    gv=$(basename "$g")
    gv=${gv#gcc-}; gv=${gv%.tar.*}
    [ -n "$gv" ] || { echo "could not work out the GCC version" >&2; exit 1; }
    echo "GCC version for the include dir: $gv"

    mkdir -v build
    cd build

    ../libstdc++-v3/configure      \
        --host="$LFS_TGT"          \
        --build="$(../config.guess)" \
        CXX="$LFS_TGT"-gcc         \
        --prefix=/usr              \
        --disable-multilib         \
        --disable-nls              \
        --disable-libstdcxx-pch    \
        --with-gxx-include-dir="/tools/$LFS_TGT/include/c++/$gv"

    make
    make DESTDIR="$LFS" install

    # libtool archive files are harmful for cross-compilation
    rm -vf "$LFS"/usr/lib/lib{stdc++{,exp,fs},supc++}.la
}
