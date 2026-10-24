# LFS chapter 5.5: Glibc (the C library), cross-compiled into $LFS.
# About 1.4 SBU and 890 MB in the book.
#
# Checked against the 13.1 book page (5.5, Glibc-2.44), except that the exact
# configure line should be compared with the page before running. The patches
# are found by name pattern, because the "upstream_fixes" patch number changes
# between point releases of the book.
#
# DANGER: "make DESTDIR=$LFS install" installs onto the HOST if LFS is empty.
# build-pkg.sh refuses to run as root or with LFS unset, and this recipe
# double-checks.
TARBALL='glibc-[0-9]*.tar.*'

build() {
    local fhs fixes interp

    case "$LFS" in ""|/) echo "glibc: LFS is not set safely" >&2; exit 1 ;; esac

    # LSB compliance link, and the compatibility link for the dynamic loader
    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 "$LFS/lib/ld-lsb.so.3"
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64"
                ln -sfv ../lib/ld-linux-x86-64.so.2 "$LFS/lib64/ld-lsb-x86-64.so.3"
        ;;
    esac

    # FHS patch (runtime data out of /var/db) and the upstream bug-fix patch
    fhs=$(tarball_path 'glibc-fhs-*.patch')
    patch -Np1 -i "$fhs"
    fixes=$(tarball_path 'glibc-*-upstream_fixes-*.patch')
    patch -Np1 -i "$fixes"

    mkdir -v build
    cd build

    # install ldconfig and sln into /usr/sbin
    echo "rootsbindir=/usr/sbin" > configparms

    ../configure                             \
          --prefix=/usr                      \
          --host="$LFS_TGT"                  \
          --build="$(../scripts/config.guess)" \
          --disable-nscd                     \
          libc_cv_slibdir=/usr/lib           \
          --enable-kernel=5.10

    make
    make DESTDIR="$LFS" install

    # fix a hard-coded path to the loader in ldd
    sed '/RTLDLIST=/s@/usr@@g' -i "$LFS/usr/bin/ldd"

    # ---- sanity checks (the book's, automated; the first two are fatal) ----
    echo 'int main(){}' | "$LFS_TGT"-gcc -x c - -v -Wl,--verbose &> dummy.log
    # "|| true": a missing/odd interpreter line is reported below, not by a silent abort
    interp=$("$LFS_TGT"-readelf -l a.out | grep -E ': (/|[A-Za-z])' | grep -i 'interpreter' || true)
    echo "$interp"
    case $(uname -m) in
        x86_64) want='[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]' ;;
        *)      want='[Requesting program interpreter: /lib/ld-linux.so.2]' ;;
    esac
    if ! printf '%s\n' "$interp" | grep -qF "$want"; then
        echo "SANITY CHECK FAILED: wrong program interpreter (wanted: $want)" >&2
        exit 1
    fi
    if ! grep -E "found ld-linux.* at $LFS/usr/lib/ld-linux" dummy.log; then
        echo "SANITY CHECK FAILED: the new dynamic loader was not found in $LFS/usr/lib" >&2
        exit 1
    fi
    echo "--- start files (should be under $LFS/lib):"
    grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log || echo "(none matched: compare with the book)"
    echo "--- libc used:"
    grep "/lib.*/libc.so.6 " dummy.log || echo "(no match: compare with the book)"
    rm -v a.out dummy.log
}
