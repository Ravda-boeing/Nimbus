# LFS chapter 5.3: GCC, pass 1 (the cross compiler). About 3.8 SBU in the book.
# GMP, MPFR and MPC are unpacked inside the GCC tree so GCC builds them itself.
#
# IMPORTANT: compare this file with the 13.1 book page for this package before
# running. The book is the authority; this file is a copy. The Glibc version for
# --with-glibc-version is read from the glibc tarball you downloaded.
TARBALL='gcc-*.tar.xz'

build() {
    local p f g gv

    for p in mpfr gmp mpc; do
        f=$(tarball_path "$p-*.tar.*")
        tar -xf "$f"
        mv -v "$(basename "${f%%.tar.*}")" "$p"
    done

    # two steps on purpose: an error inside a nested $(...) would be swallowed
    g=$(tarball_path 'glibc-*.tar.*')
    gv=$(basename "$g")
    gv=${gv#glibc-}; gv=${gv%%.tar.*}
    gv=$(echo "$gv" | cut -d. -f1,2)
    [ -n "$gv" ] || { echo "could not work out the Glibc version" >&2; exit 1; }
    echo "Glibc version for --with-glibc-version: $gv"

    # x86_64: put 64-bit libraries in lib, not lib64
    case $(uname -m) in
      x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
      ;;
    esac

    mkdir -v build
    cd build

    ../configure                  \
        --target="$LFS_TGT"       \
        --prefix="$LFS/tools"     \
        --with-glibc-version="$gv" \
        --with-sysroot="$LFS"     \
        --with-newlib             \
        --without-headers         \
        --enable-default-pie      \
        --enable-default-ssp      \
        --disable-nls             \
        --disable-shared          \
        --disable-multilib        \
        --disable-threads         \
        --disable-libatomic       \
        --disable-libgomp         \
        --disable-libquadmath     \
        --disable-libssp          \
        --disable-libvtv          \
        --disable-libstdcxx       \
        --enable-languages=c,c++

    make
    make install

    # the full internal limits.h (the one just installed is a partial one)
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        "$(dirname "$("$LFS_TGT"-gcc -print-libgcc-file-name)")/include/limits.h"
}
