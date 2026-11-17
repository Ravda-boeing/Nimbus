# LFS 13.1-systemd, Chapter 8.46: Perl 5.44.0
# Recipe format v2, built and staged with npskg.

NAME=perl
VERSION=5.44.0
TARBALL='perl-5.44.0.tar.xz'
SUMMARY='Practical Extraction and Report Language'
DEPENDS=(gdbm less ncurses zlib bzip2 libxcrypt)

build() {
    export BUILD_ZLIB=False BUILD_BZIP2=0

    sh Configure -des \
        -D prefix=/usr \
        -D vendorprefix=/usr \
        -D privlib=/usr/lib/perl5/5.44/core_perl \
        -D archlib=/usr/lib/perl5/5.44/core_perl \
        -D sitelib=/usr/lib/perl5/5.44/site_perl \
        -D sitearch=/usr/lib/perl5/5.44/site_perl \
        -D vendorlib=/usr/lib/perl5/5.44/vendor_perl \
        -D vendorarch=/usr/lib/perl5/5.44/vendor_perl \
        -D man1dir=/usr/share/man/man1 \
        -D man3dir=/usr/share/man/man3 \
        -D 'pager=/usr/bin/less -isR' \
        -D useshrplib \
        -D usethreads || return 1

    make || return 1
    local jobs
    jobs=$(nproc) || return 1
    TEST_JOBS="$jobs" make test_harness
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    unset BUILD_ZLIB BUILD_BZIP2
}
