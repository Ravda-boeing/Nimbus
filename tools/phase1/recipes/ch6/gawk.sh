TARBALL='gawk-5.4.1.tar.xz'

build() {
    sed -i 's/extras//' Makefile.in

    local build_triplet
    build_triplet=$(build-aux/config.guess)

    ./configure --prefix=/usr \
                --host="$LFS_TGT" \
                --build="$build_triplet"

    make
    make DESTDIR="$LFS" install
}
