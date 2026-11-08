# LFS 13.1, Chapter 8: Man-pages (recipe format v2, built with npskg)
# Run inside the chroot:  npskg --out /sources/pkgs build recipes/ch8/man-pages.sh
#
# The version is taken from the tarball in /sources, so this recipe keeps working if
# the book's version differs from the one listed here (6.18 in the r13.1 listing).
# The install command below is from the LFS 12.x page and has NOT been compared with
# the 13.1 page yet.
_tb=$(tarball_path 'man-pages-[0-9]*.tar.xz')
_v=${_tb##*/man-pages-}

NAME=man-pages
VERSION=${_v%.tar.xz}
TARBALL='man-pages-[0-9]*.tar.xz'
SUMMARY='Linux man pages (sections 2, 3, 4, 5 and 7)'
LICENSE='various (see the package)'

package() {
    # libxcrypt installs better crypt(3) pages later in this chapter
    rm -v man3/crypt*
    make -R GIT=false prefix=/usr DESTDIR="$PKGDIR" install
}
