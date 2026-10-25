TARBALL='gcc-16.2.0.tar.xz'

build() {
    tar -xf "$(tarball_path 'mpfr-4.2.2.tar.xz')"
    mv -v mpfr-4.2.2 mpfr

    tar -xf "$(tarball_path 'gmp-6.3.0.tar.xz')"
    mv -v gmp-6.3.0 gmp

    tar -xf "$(tarball_path 'mpc-1.4.1.tar.xz')"
    mv -v mpc-1.4.1 mpc

    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' \
                -i.orig gcc/config/i386/t-linux64
            ;;
    esac

    mkdir -v build
    cd build

    ../configure \
        --build="$(../config.guess)" \
        --host="$LFS_TGT" \
        --target="$LFS_TGT" \
        --prefix=/usr \
        --with-build-sysroot="$LFS" \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-fixincludes \
        --disable-nls \
        --disable-multilib \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libsanitizer \
        --disable-libssp \
        --disable-libvtv \
        --enable-languages=c,c++ \
        CXX_FOR_TARGET="$LFS_TGT-gcc -nostdinc++" \
        LDFLAGS_FOR_TARGET="-L$PWD/$LFS_TGT/libgcc" \
        target_configargs=gcc_cv_target_thread_file=posix

    make
    make DESTDIR="$LFS" install

    ln -sv gcc "$LFS/usr/bin/cc"
}
