# LFS 13.1-systemd, Chapter 6.2: M4-1.4.21
# Cross-compile M4 for the temporary LFS system.

TARBALL='m4-1.4.21.tar.xz'

build() {
    case "$LFS" in
        ""|/)
            echo "m4: LFS is not set safely" >&2
            exit 1
            ;;
    esac

    ./configure \
        --prefix=/usr \
        --host="$LFS_TGT" \
        --build="$(build-aux/config.guess)"

    make
    make DESTDIR="$LFS" install
}
