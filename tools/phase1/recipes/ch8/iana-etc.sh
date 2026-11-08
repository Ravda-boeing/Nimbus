# LFS 13.1, Chapter 8: Iana-Etc (recipe format v2, built with npskg)
# Run inside the chroot:  npskg --out /sources/pkgs build recipes/ch8/iana-etc.sh
#
# The book's command is `cp services protocols /etc`; here the two files go into
# the stage directory instead. The version comes from the tarball in /sources
# (20260805 in the r13.1 listing).
_tb=$(tarball_path 'iana-etc-[0-9]*.tar.gz')
_v=${_tb##*/iana-etc-}

NAME=iana-etc
VERSION=${_v%.tar.gz}
TARBALL='iana-etc-[0-9]*.tar.gz'
SUMMARY='Data for network services and protocols (/etc/services, /etc/protocols)'
LICENSE='see the package'

package() {
    install -d -m755 "$PKGDIR/etc"
    install -m644 services protocols "$PKGDIR/etc/"
}
