TARBALL='patch-2.8.tar.xz'

build() {
    local build_triplet
    build_triplet=$(build-aux/config.guess)

    ./configure --prefix=/usr \
                --host="$LFS_TGT" \
                --build="$build_triplet"

    make
    make DESTDIR="$LFS" install
}
