# LFS 13.1, Chapter 8.5: Glibc (recipe format v2, built with npskg)
#
# Build:    npskg --out /sources/pkgs build /sources/nimbus/recipes/ch8/glibc.sh
# Install:  npskg --force install /sources/pkgs/glibc-<version>.npskg   (see below)
#
# Written from the LFS development book (r13.1-39) page for Glibc-2.44, not the 13.1
# release page; patch and tzdata file names are the ones in /sources. Not run yet.
#
# - build() runs the test suite, which the book calls critical. It does NOT stop the
#   build on failures: it writes /sources/.logs/glibc-check.log and prints the failing
#   tests, so you can compare them with the book's list of usual failures BEFORE
#   installing anything.
# - The package holds Glibc plus the time zone data. The configuration files
#   (/etc/nsswitch.conf, /etc/ld.so.conf) are in the separate glibc-config recipe and
#   the locales are left for a later glibc-locales recipe.
# - Installing needs --force because the temporary Glibc's files are owned by no
#   package. Run `ldconfig` after installing.
# - Before building: remove /usr/share/config.site if it is the M4/gnulib workaround
#   (the book says so for rebuilding Glibc).
_tb=$(tarball_path 'glibc-[0-9]*.tar.xz')
_v=${_tb##*/glibc-}

NAME=glibc
VERSION=${_v%.tar.xz}
TARBALL='glibc-[0-9]*.tar.xz'
SUMMARY='The GNU C library, with time zone data'
LICENSE='LGPL-2.1-or-later'

build() {
    local S=${NPSKG_SOURCES:-/sources}
    patch -Np1 -i "$S/glibc-fhs-1.patch"
    patch -Np1 -i "$S/glibc-2.44-upstream_fixes-1.patch"

    mkdir -v build
    cd build
    ../configure --prefix=/usr                   \
                 --disable-werror                \
                 --disable-nscd                  \
                 libc_cv_slibdir=/usr/lib        \
                 --enable-stack-protector=strong \
                 --enable-kernel=5.10
    make

    # Test suite: critical per the book; a few failures are expected.
    mkdir -p /sources/.logs
    echo "glibc: running the test suite (long); log: /sources/.logs/glibc-check.log"
    make check > /sources/.logs/glibc-check.log 2>&1 \
        || echo "glibc: make check exited non-zero (a few failures are normal)"
    echo "glibc: failing tests:"
    grep -E '^(FAIL|ERROR|XPASS)' tests.sum || echo "  none"
    echo "glibc: timeouts:"
    grep "Timed out" $(find . -name '*.out') 2>/dev/null || echo "  none"
}

package() {
    local S=${NPSKG_SOURCES:-/sources}
    # (cwd is the build directory, left by build())
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
    sed '/RTLDLIST=/s@/usr@@g' -i elf/ldd

    make DESTDIR="$PKGDIR" install

    # The stage install may create these; they belong to glibc-config / ldconfig.
    rm -f "$PKGDIR/etc/ld.so.conf" "$PKGDIR/etc/ld.so.cache"
    rmdir "$PKGDIR/etc" 2>/dev/null || true

    # Time zone data (book 8.5.2.2), compiled with the zic already on the system.
    local zic; zic=$(command -v zic) || { echo "glibc: no zic found" >&2; return 1; }
    local ZONEINFO="$PKGDIR/usr/share/zoneinfo" tz
    mkdir -p tzdata
    tar -xf "$S"/tzdata[0-9]*.tar.gz -C tzdata
    ( cd tzdata
      mkdir -p "$ZONEINFO"/{posix,right}
      for tz in etcetera southamerica northamerica europe africa antarctica \
                asia australasia backward; do
          "$zic" -L /dev/null   -d "$ZONEINFO"       ${tz}
          "$zic" -L /dev/null   -d "$ZONEINFO/posix" ${tz}
          "$zic" -L leapseconds -d "$ZONEINFO/right" ${tz}
      done
      cp -v zone.tab zone1970.tab iso3166.tab "$ZONEINFO"
      "$zic" -d "$ZONEINFO" -p America/New_York
    )
}
