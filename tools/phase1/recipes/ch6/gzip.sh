TARBALL='gzip-1.14.tar.xz'

build() {
    ./configure --prefix=/usr \
                --host="$LFS_TGT"

    make
    make DESTDIR="$LFS" install
}
