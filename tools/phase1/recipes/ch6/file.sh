# LFS chapter 6.7: File (cross-compiled temporary tool). About 0.1 SBU in the book.
# The "file" program on the build host must be the same version as the one being
# built (it compiles the signature database), so a host copy is built first.
# The final rm uses -f (the book uses plain rm -v). Compare with the 13.1 page (6.7).
TARBALL='file-[0-9]*.tar.*'

build() {
    case "$LFS" in ""|/) echo "file: LFS is not set safely" >&2; exit 1 ;; esac

    # 1. temporary host copy of "file"
    mkdir build
    (
        cd build
        ../configure --disable-bzlib      \
                     --disable-libseccomp \
                     --disable-xzlib      \
                     --disable-zlib
        make
    )

    # 2. cross-compile File
    ./configure --prefix=/usr --host="$LFS_TGT" --build="$(./config.guess)"

    make FILE_COMPILE="$(pwd)/build/src/file"
    make DESTDIR="$LFS" install

    # libtool archive files are harmful for cross compilation
    rm -vf "$LFS/usr/lib/libmagic.la"

    [ -x "$LFS/usr/bin/file" ] || { echo "CHECK FAILED: file missing" >&2; exit 1; }
}
