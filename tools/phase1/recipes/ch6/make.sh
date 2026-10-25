TARBALL='make-4.4.1.tar.gz'

build() {
    local build_triplet
    build_triplet=$(build-aux/config.guess)

    ./configure --prefix=/usr \
                --host="$LFS_TGT" \
                --build="$build_triplet"

    make
    make DESTDIR="$LFS" install
}
