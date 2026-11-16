# LFS 13.1-systemd, Chapter 8.38: Grep 3.12
# Recipe format v2, built and staged with npskg.

NAME=grep
VERSION=3.12
TARBALL='grep-3.12.tar.xz'
SUMMARY='Programs for searching through the contents of files'

build() {
    sed -i 's/echo/#echo/' src/egrep.sh || return 1
    ./configure --prefix=/usr || return 1
    make || return 1
    make check
}

package() {
    make DESTDIR="$PKGDIR" install || return 1
    rm -f "$PKGDIR/usr/share/info/dir"
}
