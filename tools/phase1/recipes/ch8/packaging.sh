# LFS 13.1-systemd, Chapter 8.56: Packaging 26.3
NAME=packaging
VERSION=26.3
TARBALL='packaging-26.3.tar.gz'
SUMMARY='Python packaging specification utilities'
DEPENDS=(python flit-core)
build() { pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps "$PWD"; }
package() { pip3 install --root="$PKGDIR" --no-index --find-links dist packaging; }
