TARBALL='xz-5.8.3.tar.xz'

build() {
    local build_triplet
    build_triplet=$(build-aux/config.guess)

    ./configure --prefix=/usr \
                --host="$LFS_TGT" \
                --build="$build_triplet" \
                --disable-static \
                --docdir=/usr/share/doc/xz-5.8.3

    make
    make DESTDIR="$LFS" install

    rm -v "$LFS/usr/lib/liblzma.la"
}
