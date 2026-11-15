# LFS 13.1-systemd, Chapter 8.30: Shadow 4.20.2
# Recipe format v2, built and staged with npskg.
# The book has no test suite. Account conversion and root-password setup remain
# post-install system configuration steps, not package payload.

NAME=shadow
VERSION=4.20.2
TARBALL='shadow-4.20.2.tar.xz'
SUMMARY='Programs for secure password and account management'
DEPENDS=(acl attr libcap libxcrypt)

build() {
    # Man-pages already owns these two manual pages.
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; || return 1
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \; || return 1

    # Use yescrypt, current mailbox path, and a PATH without /bin or /sbin.
    sed -e 's:#ENCRYPT_METHOD SHA512:ENCRYPT_METHOD YESCRYPT:' \
        -e 's:/var/spool/mail:/var/mail:' \
        -e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
        -i etc/login.defs || return 1

    ./configure --sysconfdir=/etc \
                --disable-static \
                --with-{b,yes}crypt \
                --without-libbsd \
                --disable-logind \
                --with-group-name-max-length=32 || return 1

    make
}

package() {
    # Shadow's install expects its configured passwd path to exist. Create it
    # in the staging tree so it is replaced by the real binary during install.
    install -d "$PKGDIR/usr/bin" || return 1
    touch "$PKGDIR/usr/bin/passwd" || return 1

    make exec_prefix=/usr DESTDIR="$PKGDIR" install || return 1
    make -C man exec_prefix=/usr DESTDIR="$PKGDIR" install-man
}
