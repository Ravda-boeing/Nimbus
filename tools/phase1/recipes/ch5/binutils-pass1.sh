# LFS chapter 5.2: Binutils, pass 1 (the cross linker and assembler).
# Its build time is 1 SBU, the unit the book uses for every other package.
#
# IMPORTANT: compare the configure line below with the 13.1 book page for this
# package before running. The book is the authority; this file is a copy.
TARBALL='binutils-*.tar.*'

build() {
    mkdir -v build
    cd build
    ../configure --prefix="$LFS/tools" \
                 --with-sysroot="$LFS" \
                 --target="$LFS_TGT"   \
                 --disable-nls         \
                 --enable-gprofng=no   \
                 --disable-werror      \
                 --enable-default-hash-style=gnu
    make
    make install
}
