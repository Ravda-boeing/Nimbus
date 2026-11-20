# LFS r13.1-42-systemd, Chapter 8.67: IPRoute2 7.3.0
NAME=iproute2
VERSION=7.3.0
TARBALL='iproute2-7.3.0.tar.xz'
SUMMARY='IP networking and traffic control utilities'
DEPENDS=(bash coreutils glibc libcap libelf zlib)
SOURCE_MD5=b51e7e3eaf2cee927417192045f3466d
build() {
    local source_archive
    source_archive=$(tarball_path "$TARBALL") || return 1
    printf '%s  %s\n' "$SOURCE_MD5" "$source_archive" | md5sum -c - || return 1
    sed -i /ARPD/d Makefile || return 1
    rm -f man/man8/arpd.8 || return 1
    make NETNS_RUN_DIR=/run/netns
}
package() {
    make DESTDIR="$PKGDIR" SBINDIR=/usr/sbin install || return 1
    install -vDm644 COPYING README* -t "$PKGDIR/usr/share/doc/iproute2-$VERSION" || return 1
}
