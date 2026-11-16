# LFS 13.1-systemd, Chapter 8.58: Setuptools 84.0.0
NAME=setuptools
VERSION=84.0.0
TARBALL='setuptools-84.0.0.tar.gz'
SUMMARY='Python package build and installation tools'
DEPENDS=(python wheel)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() { pip3 install --root="$PKGDIR" --no-index --find-links dist setuptools; }
