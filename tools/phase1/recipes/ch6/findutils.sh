TARBALL='findutils-4.11.0.tar.xz'

build() {
    local build_triplet
    build_triplet=$(build-aux/config.guess)

    ./configure --prefix=/usr \
                --localstatedir=/var/lib/locate \
                --host="$LFS_TGT" \
                --build="$build_triplet"

    make
    make DESTDIR="$LFS" install
}
