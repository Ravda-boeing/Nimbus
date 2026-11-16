# LFS 13.1-systemd, Chapter 8.67: IPRoute2 7.1.0
NAME=iproute2
VERSION=7.1.0
TARBALL='iproute2-7.1.0.tar.xz'
SUMMARY='IP networking and traffic control utilities'
build() { sed -i /ARPD/d Makefile || return 1; rm -f man/man8/arpd.8 || return 1; make NETNS_RUN_DIR=/run/netns; }
package() { make DESTDIR="$PKGDIR" SBINDIR=/usr/sbin install || return 1; install -vDm644 COPYING README* -t "$PKGDIR/usr/share/doc/iproute2-$VERSION"; }
