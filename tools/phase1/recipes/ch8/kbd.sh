# LFS 13.1-systemd, Chapter 8.68: Kbd 2.9.0
NAME=kbd
VERSION=2.9.0
TARBALL='kbd-2.9.0.tar.xz'
SUMMARY='Keyboard utilities and keymaps'
build() { sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure || return 1; sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in || return 1; ./configure --prefix=/usr --datadir=/usr/share --disable-vlock || return 1; make || return 1; make check; }
package() { make DESTDIR="$PKGDIR" install; }
